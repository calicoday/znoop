
  # 
  #    Z-char 6789abcdef0123456789abcdef
  # current   --------------------------
  #   A0      abcdefghijklmnopqrstuvwxyz
  #   A1      ABCDEFGHIJKLMNOPQRSTUVWXYZ
  #   A2       ^0123456789.,!?_#'"/\-:()
  #           --------------------------

require "ostruct"

module Znoop
  class Abbr
    attr_reader :abbr

		# < OpenStruct or reader ostruct + dyn added methods or just mmiss to reader ostruct?
		def method_missing(m, *args, &block)
			return super unless abbr.respond_to?(m)
			abbr.send(m, *args, &block)
		end
		def respond_to_missing?(m)
			# re-sigged here
			# or... else super to raise
			abbr.respond_to?(m) || super
		end
    

    # => {:count, :table_base, :table_last, :data_base, :data_last}
#     def config_abbr(header)
    def initialize(header)
      # bail if not header
      @abbr = OpenStruct.new
      
      table_base = table_last = 0
      data_base = data_last = 0
      abbr_count = 0
    
      table_base = header.abbreviations
      return nil unless table_base

      table_count = (header.version < V3 ? 1 : 3)
      count = table_count * 32
      table_last = table_base + count * 2 - 1
  
      idx = 0
      # addr is offset!!!
      table_addr = table_base
      # get the lowest and highest of the abbr string address values in the table
      arr = count.times.map do
        prev_table_addr = table_addr
        table_addr, addr = read_data_word(prev_table_addr)
  #       table_addr, addr = read_data_word(table_addr)
        # bc this is a 'word address', recorded as half its real value...
        addr * 2
      end.reject{|e| e == 0}
      data_base, data_last = arr.minmax

  # Base    End   Size
  #     0     3f     40  Story file header
  #    40    1ef    1b0  Abbreviation data
  #   1f0    2af     c0  Abbreviation pointer table
  #   2b0    bb7    908  Object table

  #     puts "arr: #{arr.map{|e| e.to_s(16)}.inspect}"
  #     puts "data_base: #{data_base.inspect}"
  #     puts "data_last: #{data_last.inspect}"
  #     puts " is_a?(String): #{data_last.is_a?(String)}"
  #     puts " is_a?(Integer): #{data_last.is_a?(Integer)}"
  
      # avoiding copying to arr...
  #   //     count.times do |i|
  #   //       table_addr, addr = read_data_word(table_addr)
  #   //       # bc this is a 'word address', recorded as half its real value
  #   //       addr *= 2
  #   //       data_base = addr if data_base == 0 || addr < data_base
  #   //       data_last = addr if data_last == 0 || addr > data_last
  #   //     end

      #/* Scan last string to get the actual end of the string */
      last_str_words = []
      while true
        data_last, word = read_data_word(data_last)
        last_str_words << word
        break if zlast_word?(word)
      end
    
  #     data_last -= 2 ### for word surely??? -= 1
      data_last -= 1
    
      abbr.count = count
      abbr.table_base = table_base
      abbr.table_last = table_last
      abbr.data_base = data_base
      abbr.data_last = data_last
#       {count: count, table_base: table_base, table_last: table_last, 
#         data_base: data_base, data_last: data_last}
    end

  # 239] pry(main)> def word_to_decode(w)
  # [239] pry(main)*   i = w.to_i(16)
  # [239] pry(main)*   bstr = '%0*b' % [16, i]
  # [239] pry(main)*   codes = bstr.unpack('a1a5a5a5')
  # [239] pry(main)*   mark, *codes = bstr.unpack('a1a5a5a5')
  # [239] pry(main)*   [mark != 0, codes.map{|e| e.to_i(2).to_s(16)}].flatten
  # [239] pry(main)* end  

  # 3.2.2
  # In Versions 1 and 2, the current alphabet can be any of the three. 
  # The Z-characters 2 and 3 are called 'shift' characters and change 
  # the alphabet for the next character only. The new alphabet depends on 
  # what the current one is:
  # 
  #              from A0  from A1  from A2
  #   Z-char 2      A1       A2       A0
  #   Z-char 3      A2       A0       A1
  #   
  # Z-characters 4 and 5 permanently change alphabet, according to the 
  # same table, and are called 'shift lock' characters.
  # 
  # 3.2.3
  # In Versions 3 and later, the current alphabet is always A0 unless 
  # changed for 1 character only: Z-characters 4 and 5 are shift characters. 
  # Thus 4 means "the next character is in A1" and 5 means "the next is in A2". 
  # There are no shift lock characters.
  # 
  # 3.2.4
  # An indefinite sequence of shift or shift lock characters is legal 
  # (but prints nothing).
  # 
  # 3.3
  # In Versions 3 and later, Z-characters 1, 2 and 3 represent abbreviations, 
  # sometimes also called 'synonyms' (for traditional reasons): the next 
  # Z-character indicates which abbreviation string to print. If z is the 
  # first Z-character (1, 2 or 3) and x the subsequent one, then the interpreter 
  # must look up entry 32(z-1)+x in the abbreviations table and print the string 
  # at that word address. In Version 2, Z-character 1 has this effect (but 2 and 3 
  # do not, so there are only 32 abbreviations).
  # 
  ### only vers 3, so 
  # '0' => output ' ' [space]
  # '1' to '3' => output '' [nothing]
  # '4' => shift to :a1 output '' [nothing]
  # '5' => shift to :a2, output '' [nothing]
  
    def zmask  
      @zmask ||= {
        mark:   0b1000000000000000, # ie 0x8000
        char_0: 0b0111110000000000,
        char_1: 0b0000001111100000,
        char_2: 0b0000000000011111,
        }
    end
    def zlast_word?(word) (word & zmask[:mark]) != 0 end

    # => [mark, char_0, char_1, char_2] (mark is true/false highest bit set)
    def zdecode(word)
  ##     zmasks.values.map{|mask| word & mask}.tap{|arr| arr[0] = (arr[0] != 0)}
  #     content = zmask.values.map{|mask| word & mask}
  #     content[0] = (content[0] != 0)
  #     content
      [(word & zmask[:mark]) != 0,
        (word & zmask[:char_0]) >> 10,
        (word & zmask[:char_1]) >> 5,
        (word & zmask[:char_2])]
    end
  
    def alpha(key, reg=:a0)
      reg = (reg.is_a?(Integer) ? "a#{reg}".to_sym : reg)
      key = (key.is_a?(Integer) ? key.to_s(16) : key)
      @_alpha[reg][key]
    end
  
    # make a choice of Integer or String for key, prev!!!
    def adj_alpha(key, prev)
      reg = case prev
      when '4', 4 then :a1
      when '5', 5 then :a2
      else
        :a0
      end
      alpha(key, reg)
    end

    def zcodes_alpha(zcodes)
      prev = nil
      zcodes.map{|c| a = adj_alpha(c, prev); prev = c; a}.join
    end

    def config_alpha
  #     return @_alpha if @_alpha #???
      # '0' for space, in all registers???
      # '5' used for post-padding, what about '2', '3' shifters???
      also = "012345".chars.zip([' ', '', '', '', '', ''])
      keys = (0x6..0x1f).map{|e| e.to_s(16)}
      @_alpha = {
        a0: (also + keys.zip("abcdefghijklmnopqrstuvwxyz".chars)).to_h,
        a1: (also + keys.zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ".chars)).to_h,
        a2: (also + keys.zip(" ^0123456789.,!?_#'\"/\\-:()".chars)).to_h
        }
    end

    def will_zlast_word?(word) 
#       zmask{mark:   0b1000000000000000, # ie 0x8000
      (word & 0x8000) != 0 
    end
    
    def word_to_decode(w)
      i = w.to_i(16)
      bstr = '%0*b' % [16, i]
      mark, *codes = bstr.unpack('a1a5a5a5')
      [mark != "0", codes.map{|e| e.to_i(2).to_s(16)}].flatten
    end
    
  # [184] pry(main)> d = '%0*b' % [16, "d1 60".split.map{|e|e.to_i(16)}.join]
  # => "0101001000000100"
  # [185] pry(main)> d.length
  # => 16

    def zdecode_text(offset)
      zcodes = []
      while true
        offset, word = read_data_word(offset)
        mark, *trio = zdecode(word)
        zcodes += trio
        break if mark
      end
      [offset, zcodes]
    end
  
#     def show_abbr(w=nil)
    def show(w=nil)
      unless w
        immed = true
        w = Writer.new
      end
    
    
 
#       abbr = @_abbr
    
      puts "abbr: #{abbr.map{|k,v| [k, v.to_s(16)]}.to_h.inspect}"
  #     abbr[0, 5].each_with_index do |e, i|
  #     end

  # oho = aha.chunk_while{|a,b| a !~ /\A;[ \t]*\n/}.map(&:join)
      data_chunk_raw = datap[0x40..0x1ef]
      data_chunk = data_chunk_raw.unpack('C*').map{|e| sprintf("%02x", e)}
        .each_slice(2).map{|a,b| a + b}
        .chunk_while{|a,b| zlast_word?(b.to_i(16))}.to_a
  #     puts "g len: #{data_chunk.length}, hex: #{data_chunk.inspect}"
    
      w.line("\n    **** Abbreviations ****\n\n")
    
      config_alpha
    
      if abbr[:count] == 0
        w.line("No abbreviation information.\n")   
      else
        table_addr = abbr[:table_base]
        abbr[:count].times do |i|
          table_addr, abbr_addr = read_data_word(table_addr)
          abbr_addr *= 2
          offset, zcodes = zdecode_text(abbr_addr)
          w.line("[%2d] \"%s\"\n", i, zcodes_alpha(zcodes)) 
        end   
      end
  
      w.put if immed
    end

  end
  
end