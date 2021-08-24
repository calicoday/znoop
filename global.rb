H_VERSION = 0
H_CONFIG = 1

CONFIG_BYTE_SWAPPED = 0x01 #/* Game data is byte swapped          - V3  */
CONFIG_COLOUR = 0x01 #/* Interpreter supports colour        - V5+ */
CONFIG_TIME = 0x02 #/* Status line displays time          - V3  */
CONFIG_PICTURES = 0x02 #/* Interpreter supports pictures      - V6  */
CONFIG_BOLDFACE = 0x04 #/* Interpreter supports bold text     - V4+ */
CONFIG_TANDY = 0x08 #/* Tandy licensed game                - V3  */
CONFIG_EMPHASIS = 0x08 #/* Interpreter supports text emphasis - V4+ */
CONFIG_NOSTATUSLINE = 0x10 #/* Interpreter has no status line     - V3  */
CONFIG_FIXED_FONT = 0x10 #/* Interpreter supports fixed font    - V4+ */
CONFIG_WINDOWS = 0x20 #/* Interpreter supports split screen  - V3  */
CONFIG_PROPORTIONAL = 0x40 #/* Interpreter uses proportional font - V3  */
CONFIG_TIMEDINPUT = 0x80 #/* Interpreter supports timed input   - V4+ */

H_RELEASE = 2
H_RESIDENT_SIZE = 4
H_START_PC = 6
H_DICTIONARY = 8
H_OBJECTS = 10
H_GLOBALS = 12
H_DYNAMIC_SIZE = 14
H_FLAGS = 16

SCRIPTING_FLAG = 0x0001
FIXED_FONT_FLAG = 0x0002
REFRESH_FLAG = 0x0004
GRAPHICS_FLAG = 0x0008
OLD_SOUND_FLAG = 0x0010 #/* V3 */
UNDO_AVAILABLE_FLAG = 0x0010 #/* V5 */
MOUSE_FLAG = 0x0020
COLOUR_FLAG = 0x0040
NEW_SOUND_FLAG = 0x0080
MENU_FLAG = 0x0100

H_SERIAL = 18
H_ABBREVIATIONS = 24
H_FILE_SIZE = 26
H_CHECKSUM = 28
H_INTERPRETER_NUMBER = 30

INTERP_GENERIC = 0
INTERP_DEC_20 = 1
INTERP_APPLE_IIE = 2
INTERP_MACINTOSH = 3
INTERP_AMIGA = 4
INTERP_ATARI_ST = 5
INTERP_MSDOS = 6
INTERP_CBM_128 = 7
INTERP_CBM_64 = 8
INTERP_APPLE_IIC = 9
INTERP_APPLE_IIGS = 10
INTERP_TANDY = 11

H_INTERPRETER_VERSION = 31
H_SCREEN_ROWS = 32
H_SCREEN_COLUMNS = 33
H_SCREEN_WIDTH = 34
H_SCREEN_HEIGHT = 36
H_FONT_WIDTH = 38 #/* this is the font height in V6 */
H_FONT_HEIGHT = 39 #/* this is the font width in V6 */
H_ROUTINES_OFFSET = 40
H_STRINGS_OFFSET = 42
H_DEFAULT_BACKGROUND = 44
H_DEFAULT_FOREGROUND = 45
H_TERMINATING_KEYS = 46
H_LINE_WIDTH = 48
H_SPECIFICATION_HI = 50
H_SPECIFICATION_LO = 51
H_ALPHABET = 52
H_MOUSE_TABLE = 54
H_NAME = 56

V1 = 1

V2 = 2

#/* Version 3 object format */

V3 = 3

### to object.rb ???
# typedef struct zobjectv3 {
#     zword_t attributes[2];
#     zbyte_t parent;
#     zbyte_t next;
#     zbyte_t child;
#     zword_t property_offset;
# } zobjectv3_t;

O3_ATTRIBUTES = 0
O3_PARENT = 4
O3_NEXT = 5
O3_CHILD = 6
O3_PROPERTY_OFFSET = 7

O3_SIZE = 9

#define PARENT3(offset) (offset + O3_PARENT)
#define NEXT3(offset) (offset + O3_NEXT)
#define CHILD3(offset) (offset + O3_CHILD)

P3_MAX_PROPERTIES = 0x20

#/* Version 4 object format */

V4 = 4

### unnec!!!
# typedef struct zobjectv4 {
#     zword_t attributes[3];
#     zword_t parent;
#     zword_t next;
#     zword_t child;
#     zword_t property_offset;
# } zobjectv4_t;

O4_ATTRIBUTES = 0
O4_PARENT = 6
O4_NEXT = 8
O4_CHILD = 10
O4_PROPERTY_OFFSET = 12

O4_SIZE = 14

#define PARENT4(offset) (offset + O4_PARENT)
#define NEXT4(offset) (offset + O4_NEXT)
#define CHILD4(offset) (offset + O4_CHILD)

P4_MAX_PROPERTIES = 0x40

V5 = 5

V6 = 6

V7 = 7

V8 = 8

#/* Local defines */

PAGE_SIZE = 512
PAGE_MASK = 511
PAGE_SHIFT = 9

_NIL = 0 ### handle specially!!!
ANYTHING = 1
VAR = 2
NUMBER = 3
LOW_ADDR = 4
ROUTINE = 5
OBJECT = 6
STATIC = 7
LABEL = 8
PCHAR = 9
VATTR = 10
PATTR = 11
INDIRECT = 12
PROPNUM = 13
ATTRNUM = 14

NONE = 0
TEXT = 1
STORE = 2
BRANCH = 3
BOTH = 4

PLAIN = 0
CALL = 1
RETURN = 2
ILLEGAL = 3

TWO_OPERAND = 0
ONE_OPERAND = 1
ZERO_OPERAND = 2
VARIABLE_OPERAND = 3
EXTENDED_OPERAND = 4

WORD_IMMED = 0
BYTE_IMMED = 1
VARIABLE = 2
NO_OPERAND = 3

END_OF_CODE = 1
END_OF_ROUTINE = 2
END_OF_INSTRUCTION = 3
BAD_ENTRY = 4
BAD_OPCODE = 5

ROMAN = 0
REVERSE = 1
BOLDFACE = 2
EMPHASIS = 4
FIXED_FONT = 8

#/* Grammar related defines */

# enum parser_types {
# 	infocom_fixed,
# 	infocom_variable,
# 	infocom6_grammar,
# 	inform5_grammar,
# 	inform_gv1,
# 	inform_gv2,
# 	inform_gv2a
# };

#define VERB_NUM(index, parser_type) (((parser_type) >= inform_gv2a)?(index):((unsigned int)(255-(index))))

PREP = 0x08
DESC = 0x20	#/* infocom V1-5 only -- actually an adjective. */
NOUN = 0x80
VERB = 0x40	#/* infocom V1-5 only */
DIR = 0x10 	#/* infocom V1-5 only */
VERB_INFORM = 0x01
VERB_V6 = 0x01
PLURAL = 0x04 	#/* inform only */
SPECIAL = 0x04 	#/* infocom V1-5 only */
META = 0x02 	#/* infocom V1-5 only */
DATA_FIRST = 0x03 	#/* infocom V1-5 only */
DIR_FIRST = 0x03  	#/* infocom V1-5 only */
ADJ_FIRST = 0x02  	#/* infocom V1-5 only */
VERB_FIRST = 0x01  	#/* infocom V1-5 only */
PREP_FIRST = 0x00  	#/* infocom V1-5 only */
ENDIT = 0x0F

#/* txd-specific defines? */

MAX_CACHE = 10

# typedef struct decode_t {
#     unsigned int  first_pass;   #/* Code pass flag                   */
#     unsigned long pc;           #/* Current PC                       */
#     unsigned long initial_pc;   #/* Initial PC                       */
#     unsigned long high_pc;      #/* Highest PC in current subroutine */
#     unsigned long low_address;  #/* Lowest subroutine address        */
#     unsigned long high_address; #/* Highest code address             */
# } decode_t;

# typedef struct opcode_t {
#     int opcode;  #/* Current opcode  */
#     int class;   #/* Class of opcode */
#     int par[4];  #/* Types of parameters */
#     int extra;   #/* Branch/store/text */
#     int type;    #/* Opcode type */
# } opcode_t;

# typedef struct cref_item_s {
#     struct cref_item_s *next;
#     struct cref_item_s *child;
#     unsigned long address;
#     int number;
# } cref_item_t;

#/* Data access macros */

#define get_byte(offset) ((zbyte_t) datap[offset])
#define get_word(offset) ((zword_t) (((unsigned short) datap[offset] << 8) + (unsigned short) datap[offset + 1]))
#define set_byte(offset,value) datap[offset] = (zbyte_t) (value)
#define set_word(offset,value) datap[offset] = (zbyte_t) ((unsigned short) (value) >> 8), datap[offset + 1] = (zbyte_t) ((unsigned short) (value) & 0xff)

def data_size() $datap.length end
def datap() $datap end ### or whatever!!! array or string???
def get_byte(offset) datap[offset].unpack('C*')[0] end
def get_word(offset) datap[offset, 2].unpack('S>*')[0] end
# def get_word(offset) 
#   raw = datap[offset, 2]
#   cook = raw.unpack('S>*')[0] 
# #   puts "get_word offset: #{offset.to_s(16)}, raw: #{raw}, cook: #{cook.to_s(16)}"
#   cook
# end
def set_byte(offset, value) datap[offset] = value end # encode??? FIXME!!!
def set_word(offset, value) datap[offset, 2] = value[0, 2] end #encode??? FIXME!!!

# for now, we don't page the data... unpack???
def read_data_byte(offset) [offset + 1, get_byte(offset)] end
def read_data_word(offset) [offset + 2, get_word(offset)] end
# def read_data_byte(offset) [offset + 1, datap[offset]] end
# def read_data_word(offset) [offset + 2, datap[offset, 2]] end



#/* External data */

# extern zheader_t header;
# 
# extern int story_scaler;
# extern int story_shift;
# extern int code_scaler;
# extern int code_shift;
# extern int property_mask;
# extern int property_size_mask;
# 
# extern zbyte_t *datap;
# 
# extern option_inform;
# 
# extern unsigned long file_size;


#/* Inform version codes */
INFORM_5 = 500
INFORM_6 = 600
INFORM_610 = 610
