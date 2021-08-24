require "ostruct"
require "awesome_print"

module Znoop
  class Header
    attr_reader :header

    def put_stuff
      plan = self.instance_variables.map{|k| [k, self.instance_variable_get(k)]}.to_h
      puts plan.inspect
      puts "==="
      ap plan
    end

		# < OpenStruct or reader ostruct + dyn added methods or just mmiss to reader ostruct?
		def method_missing(m, *args, &block)
			return super unless header.respond_to?(m)
			header.send(m, *args, &block)
		end
		def respond_to_missing?(m)
			# re-sigged here
			# or... else super to raise
			header.respond_to?(m) || super
		end
    
    def get_byte_or_word(prop, type)
      const = "H_#{prop.to_s.upcase}"
      puts "#{prop.inspect}, #{const}"
      offset = Object.const_get("H_#{prop.to_s.upcase}")
      type == :zword_t ? get_word(offset) : get_byte(offset)
    end
    def initialize
      # bail if not datap
      @header = OpenStruct.new
      
      ### only doing vers 3!!! where'd i get these???
      serial_size = 6
      name_size = 8

      # struct header body (ztools/tx.h): s/^\s*(\w+)\s+(\w+)[^;]*;/\t\t\t[:\2, :\1], /g
			[[:version, :zbyte_t], 
			[:config, :zbyte_t], 
			[:release, :zword_t], 
			[:resident_size, :zword_t], 
			[:start_pc, :zword_t], 
			[:dictionary, :zword_t], 
			[:objects, :zword_t], 
			[:globals, :zword_t], 
			[:dynamic_size, :zword_t], 
			[:flags, :zword_t], 
			[:serial, :zbyte_t], 
			[:abbreviations, :zword_t], 
			[:file_size, :zword_t], 
			[:checksum, :zword_t], 
			[:interpreter_number, :zbyte_t], 
			[:interpreter_version, :zbyte_t], 
			[:screen_rows, :zbyte_t], 
			[:screen_columns, :zbyte_t], 
			[:screen_width, :zword_t], 
			[:screen_height, :zword_t], 
			[:font_width, :zbyte_t], 
			[:font_height, :zbyte_t], 
			[:routines_offset, :zword_t], 
			[:strings_offset, :zword_t], 
			[:default_background, :zbyte_t], 
			[:default_foreground, :zbyte_t], 
			[:terminating_keys, :zword_t], 
			[:line_width, :zword_t], 
			[:specification_hi, :zbyte_t], 
			[:specification_lo, :zbyte_t], 
			[:alphabet, :zword_t], 
			[:mouse_table, :zword_t], 
			[:name, :zbyte_t]].each do |prop, type|
			  case prop
			  when :serial
#           serial_size = 6 # above
          header[prop] = serial_size.times.map{|i| get_byte(H_SERIAL + i)} #.join
#           self.serial = serial_size.times.map{|i| get_byte(H_SERIAL + i)} #.join
			  when :file_size
			    # header.file_size is used to calc the ACTUAL file_size -- put this where???
			    # just make it global for now!!! prob header prop and make data file_size_raw
			    header[prop] = get_byte_or_word(prop, type)
			    
          $file_size = case
          when header.version == 0 then get_story_size()
          when header.version <= V3 then header[prop] * 2
          when header.version <= V5 then header[prop] * 4
          else 
            header[prop] * 8
          end
			  when :font_width
			    # prop = :font_height if header[:version] >= 6 # flop w/h ### do we care???
			    header[prop] = get_byte_or_word(prop, type)
			  when :font_height
			    # prop = :font_width if header[:version] >= 6 # flop w/h ### do we care???
			    header[prop] = get_byte_or_word(prop, type)
			  when :name
#           name_size = 8 # above
          header[prop] = name_size.times.map{|i| get_byte(H_NAME + i)} #.join
#           self.name = name_size.times.map{|i| get_byte(H_NAME + i)} #.join
			  else
			    header[prop] = get_byte_or_word(prop, type)
			  end
			  
			  # and add reader to hash??? argh!!!
			end

    end
    def get_story_size() 
      # what should this be??? ### do we care???
      raise "get_story_size not impl." 
    end

    def serial_not_1980s
      # looks to me like the serial number is, or started as, a 6-digit date
      # and we use it to trigger setting the inform number after 1989
      header.serial =~ /[0-79][0-9][01][0-9][0-3][0-9]/
    end

    ### stuff from showhead.c
    def show(w=nil)
      unless w
        immed = true
        w = Znoop::Writer.new
      end
    
      inform = 0
      if serial_not_1980s
        # if name[4] is < 6, call it 5
        inform = (header.name[4].to_i >= 6 ? header.name[4].to_i : 5)
      end

      w.line("\n    **** Story file header ****\n\n")

      w.line("Z-code version:           %d\n", header.version)

  #     tx_fix_margin (1); ### some sort of indent thing rel v6 text, ignore for now!!!
      labels = (header.version < V4 ? interpreter_flags1 : interpreter_flags2)
      flags = 8.times.map{|i| (header.config & (1 << i)) == 0 ? nil : labels[i]}
  #     tx_fix_margin (0);
    
      # pre v4, add 'display score' label if we haven't got 'display time' label
      flags[1] = "Display score/moves" if header.version < V4 && flags[1].nil?
      gather = flags.compact.join(', ')
      gather = "None" if gather == ''
      w.line("Interpreter flags:        %s\n", gather)

      w.line("Release number:           %d\n", header.release)
      w.line("Size of resident memory:  %04x\n", header.resident_size)

      if header.version != V6
          w.line("Start PC:                 %04x\n", header.start_pc)
      end
  #     else
  #         tx_printf ("Main routine address:     %05lx\n", (unsigned long)
  #                    (((unsigned long) header.start_pc * code_scaler) +
  #                     ((unsigned long) header.routines_offset * story_scaler)));

      w.line("Dictionary address:       %04x\n", header.dictionary)
      w.line("Object table address:     %04x\n", header.objects)
      w.line("Global variables address: %04x\n", header.globals)
      w.line("Size of dynamic memory:   %04x\n", header.dynamic_size)

  #     tx_fix_margin (1);
      labels = (header.version < V4 ? game_flags1 : game_flags2)
      flags = 16.times.map{|i| (header.flags & (1 << i)) == 0 ? nil : labels[i]}
  #     tx_fix_margin (0);
      gather = flags.compact.join(', ')
      gather = "None" if gather == ''
      w.line("Game flags:               %s\n", gather)

      w.line("Serial number:            %s\n", header.serial.map(&:chr).join)
    
      if header.abbreviations != 0
        w.line("Abbreviations address:    %04x\n", header.abbreviations) 
      end
    
      if header.file_size != 0
        w.line("File size:                %05x\n", $file_size)
  #       w.line("File size:                %05x\n", header.file_size_calc)
        w.line("Checksum:                 %04x\n", header.checksum)
      end

      ### only ver 3!!!
  #     /* Inform version -- overlaps name */
  #     if inform >= 6
  #       w.line("Inform Version:           %s\n", header.name[4, -1].map(&:chr).join)
  #     end

      w.put if immed
    end
    
    def interpreter_flags1
      @_interpreter_flags1 ||= ["Byte swapped data",
      "Display time",
      "Unknown (0x04)",
      "Tandy",
      "No status line",
      "Windows available",
      "Proportional fonts used",
      "Unknown (0x80)"]
    end

    def interpreter_flags2
      @_interpreter_flags2 ||= ["Colours",
      "Pictures",
      "Bold font",
      "Emphasis",
      "Fixed space font",
      "Unknown (0x20)",
      "Unknown (0x40)",
      "Timed input"]
    end

    def game_flags1
      @_game_flags1 ||= ["Scripting",
      "Use fixed font",
      "Unknown (0x0004)",
      "Unknown (0x0008)",
      "Supports sound",
      "Unknown (0x0010)",
      "Unknown (0x0020)",
      "Unknown (0x0040)",
      "Unknown (0x0080)",
      "Unknown (0x0200)",
      "Unknown (0x0400)",
      "Unknown (0x0800)",
      "Unknown (0x1000)",
      "Unknown (0x2000)",
      "Unknown (0x4000)",
      "Unknown (0x8000)"]
    end

    def game_flags2
      @_game_flags2 ||= ["Scripting",
      "Use fixed font",
      "Screen refresh required",
      "Supports graphics",
      "Supports undo",
      "Supports mouse",
      "Supports colour",
      "Supports sound",
      "Supports menus",
      "Unknown (0x0200)",
      "Printer error",
      "Unknown (0x0800)",
      "Unknown (0x1000)",
      "Unknown (0x2000)",
      "Unknown (0x4000)",
      "Unknown (0x8000)"]
    end
    
  end
end