# cython: language_level=3
from libc.stdio cimport FILE


cdef extern from "friso_API.h" nogil:
    ctypedef char * fstring
    ctypedef unsigned short ushort_t
    ctypedef unsigned char uchar_t
    ctypedef unsigned int uint_t

    ctypedef  struct friso_hash_cdt:
        pass
    ctypedef friso_hash_cdt * friso_hash_t

    ctypedef struct friso_array_entry:
        pass
    struct friso_link_node:
        pass

    ctypedef  friso_link_node link_node_entry
    ctypedef link_node_entry * link_node_t
    ctypedef friso_array_entry * friso_array_t
    ctypedef struct friso_link_entry:
        link_node_t head
        link_node_t tail
        uint_t size


    ctypedef friso_link_entry * friso_link_t
    ctypedef struct  string_buffer_entry:
        fstring buffer
        uint_t length
        uint_t allocs
    ctypedef string_buffer_entry * string_buffer_t

    ctypedef struct string_split_entry:
        fstring source
        uint_t srcLen
        fstring delimiter
        uint_t delLen
        uint_t idx
    ctypedef string_split_entry * string_split_t
    string_split_t new_string_split( fstring f1, fstring f2)
    void string_split_reset( string_split_t s, fstring f1, fstring f2)
    void string_split_set_source( string_split_t s, fstring f)
    void string_split_set_delimiter( string_split_t s, fstring f)
    void free_string_split( string_split_t s)
    fstring string_split_next(string_split_t s, fstring f)


cdef extern from "friso.h" nogil:
    fstring friso_version()
    ctypedef enum friso_lex_t:
        __LEX_CJK_WORDS__
        __LEX_CJK_UNITS__
        __LEX_ECM_WORDS__    #english and chinese mixed words.
        __LEX_CEM_WORDS__    #chinese and english mixed words.
        __LEX_CN_LNAME__
        __LEX_CN_SNAME__
        __LEX_CN_DNAME1__
        __LEX_CN_DNAME2__
        __LEX_CN_LNA__
        __LEX_STOPWORDS__
        __LEX_ENPUN_WORDS__
        __LEX_EN_WORDS__
        __LEX_OTHER_WORDS__
        __LEX_NCSYN_WORDS__
        __LEX_PUNC_WORDS__      #punctuations
        __LEX_UNKNOW_WORDS__      #unrecognized words.
    ctypedef friso_hash_t * friso_dic_t

    ctypedef enum friso_charset_t:
        FRISO_UTF8
        FRISO_GBK

    ctypedef enum friso_mode_t:
        __FRISO_SIMPLE_MODE__
        __FRISO_COMPLEX_MODE__
        __FRISO_DETECT_MODE__

    ctypedef struct friso_entry:
        friso_dic_t dic        #friso dictionary
        friso_charset_t charset   #project charset.

    ctypedef friso_entry * friso_t
    ctypedef struct lex_entry_cdt:
        uchar_t length    #the length of the token.(after the convertor of Friso.)
        uchar_t rlen      #the real length of the token.(before any convert)
        uchar_t type
        uchar_t ctrlMask  #function control mask, like append the synoyums words.
        uint_t offset     #offset index.
        fstring word
       #fstring py      #pinyin of the word.(invalid)
        friso_array_t syn #synoyums words.
        friso_array_t pos #part of speech.
        uint_t fre        #single word frequency.
    ctypedef lex_entry_cdt * lex_entry_t
    ctypedef struct friso_token_entry:
        uchar_t type   #type of the word. (item of friso_lex_t)
        uchar_t length #length of the token.
        uchar_t rlen   #the real length of the token.(in orgin strng)
        char pos       #part of speech.
        int offset    #start offset of the word.
        char *word
    ctypedef friso_token_entry * friso_token_t

    ctypedef struct friso_task_entry:
        fstring text           # text to tokenize
        uint_t idx             # start offset index.
        uint_t length          # length of the text.
        uint_t bytes           # latest word bytes in C.
        uint_t unicode_ "unicode"         # latest word unicode number.
        uint_t ctrlMask        # action control mask.
        friso_link_t pool      # task pool.
        string_buffer_t sbuf   # string buffer.
        friso_token_t token    # token result token
        char buffer[7]         # word buffer. (1-6 bytes for an utf-8 word in C).

    ctypedef friso_task_entry * friso_task_t
    int _FRISO_KEEP_PUNC_LEN
    ctypedef friso_token_t (*next_token) (friso_t friso, friso_config_struct* cfg, friso_task_t task)
    ctypedef lex_entry_t   (*next_cjk) (friso_t friso, friso_config_struct* cfg, friso_task_t task)
    struct friso_config_struct:
        ushort_t max_len            # the max match length (4 - 7).
        ushort_t r_name            # 1 for open chinese name recognition 0 for close it.
        ushort_t mix_len            # the max length for the CJK words in a mix string.
        ushort_t lna_len            # the max length for the chinese last name adron.
        ushort_t add_syn            # append synonyms tokenizer words.
        ushort_t clr_stw            # clear the stopwords.
        ushort_t keep_urec         # keep the unrecongnized words.
        ushort_t spx_out            # use sphinx output customize.
        ushort_t en_sseg            # start the secondary segmentation.
        ushort_t st_minl            # min length of the secondary segmentation token.
        uint_t nthreshold            # the threshold value for a char to make up a chinese name.
        friso_mode_t mode            # Complex mode or simple mode

        # pointer to the function to get the next token
        next_token next_token
        # pointer to the function to get the next cjk lex_entry_t
        next_cjk   next_cjk

        char *kpuncs # keep punctuations buffer.
    ctypedef  friso_config_struct friso_config_entry
    ctypedef friso_config_entry * friso_config_t
    friso_t friso_new()
    int friso_init_from_ifile(friso_t friso, friso_config_t cfg, fstring s)
    void friso_free(friso_t)
    void friso_set_dic(friso_t friso, friso_dic_t dic)
    void friso_set_mode(friso_config_t cfg, friso_mode_t mod)
    friso_config_t friso_new_config( )
    void friso_init_config(friso_config_t cfg)
    void friso_free_config(friso_config_t cfg)
    friso_task_t friso_new_task( )
    void friso_free_task(friso_task_t task)
    friso_token_t friso_new_token()
    void friso_free_token( friso_token_t token)
    void friso_set_text(friso_task_t task, fstring s)
    lex_entry_t next_simple_cjk(friso_t friso, friso_config_t cfg, friso_task_t task)
    lex_entry_t next_complex_cjk(friso_t friso, friso_config_t cfg, friso_task_t task)
    friso_token_t next_mmseg_token(friso_t friso, friso_config_t cfg, friso_task_t task)
    friso_token_t next_detect_token(friso_t friso, friso_config_t cfg, friso_task_t task)
    friso_dic_t friso_dic_new( )
    fstring file_get_line(fstring s, FILE * f)
    void friso_dic_free(friso_dic_t d)
    lex_entry_t new_lex_entry(fstring f , friso_array_t a, uint_t p1, uint_t p2, uint_t p3)
    void free_lex_entry_full(lex_entry_t lex)
    void free_lex_entry(lex_entry_t lex)
    void friso_dic_load(friso_t  friso, friso_config_t cfg, friso_lex_t lex, fstring f, uint_t p)
    void friso_dic_load_from_ifile(friso_t friso, friso_config_t cfg, fstring path, uint_t length)
    void friso_dic_add(friso_dic_t d, friso_lex_t lex, fstring f, friso_array_t a)
    void friso_dic_add_with_fre(friso_dic_t d, friso_lex_t lex, fstring f, friso_array_t a, uint_t p)
    int friso_dic_match(friso_dic_t d, friso_lex_t lex, fstring f)
    lex_entry_t friso_dic_get(friso_dic_t d, friso_lex_t lex, fstring f)
    uint_t friso_spec_dic_size(friso_dic_t d, friso_lex_t lex)
    uint_t friso_all_dic_size(friso_dic_t d)
