require './global.rb'
require './header.rb'
require './abbr.rb'

module Znoop

  class Writer
    def initialize() @s = "" end
    def line(*args) @s += sprintf(*args) end
    def put() puts @s end
  end

# extern void show_header ();
# extern void show_abbreviations ();
# extern void show_dictionary ();
# extern void show_objects ();
# extern void show_tree ();
# extern void show_verbs ();
# 
# static void show_help ();
# static void process_story ();
# static void fix_dictionary ();
# static void show_map ();

#   def self.run(*args)
#   end
  class Runner
    def self.run(datafile)
      $datap = IO.read(datafile, mode: 'rb')

#       config_globals
      
      hdr = Header.new
      puts "+++"
      hdr.show

      abbr = Abbr.new(hdr)
#       puts "&&&"
#       abbr.show

      puts "***"
      show_map(hdr, abbr)
#       MemMap.new.show_map(hdr)
    end
 

    ### was MemMap#show_map

    def self.mk_area(base, last, name) {base: base, last: last, name: name} end

    def self.show_map(header, abbr, w=nil)
      unless w
        immed = true
        w = Writer.new
      end
    
      areas = []

      areas << mk_area(0, 63, "Story file header")
  #     set_area (area, 0, 63, "Story file header");

      base = header.mouse_table
      if base != 0
        size = get_word(base)
        last = base + 2 + size * 2 - 1
        areas << mk_area(base, last, "Header extension table")
        if size > 2
          uni_base = get_word(base + 6)
          if uni_base != 0
            uni_last = uni_base + get_byte(uni_base) * 2
            areas << mk_area(uni_base, uni_last, "Unicode table")
          end
        end
      end      
  
      # give abbr mk_area resp???
      if abbr.count != 0
        areas << mk_area(abbr.table_base, abbr.table_last, "Abbreviation pointer table")
        areas << mk_area(abbr.data_base, abbr.data_last, "Abbreviation data")
      end

      # sort areas
    #   matrix.sort_by { |obj| obj.size }
    #   areas = areas.sort_by{|e| e[:base]}
      areas = areas.sort{|a, b| a[:base] <=> b[:base]}
  
      w.line("\n    **** Story file map ****\n\n")
      w.line(" Base    End   Size\n")
      prev_last = nil
      areas.each do |e|
        # if there's a gap between the this base and prev last, note it
        if prev_last && ((e[:base] - 1) > prev_last)
    #       w.line("%5x  %5x  %5x  [gap]\n", prev_last + 1, 
          w.line("%5x  %5x  %5x\n", prev_last + 1, 
            e[:base] - 1, (e[:base] - 1) - (prev_last + 1) + 1)
        end
        prev_last = e[:last]
        w.line("%5x  %5x  %5x  %s\n", e[:base], e[:last], 
          e[:last] - e[:base] + 1, e[:name])
      end

      
#       show_abbr(w)
      abbr.show(w)
      
  
      w.put if immed

    end 
 
  end
end