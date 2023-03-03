# cython: language_level=3
cimport cython
from libc.stdint cimport uint8_t

# from cpython.bytes cimport PyBytes_FromStringAndSize
from friso.backends.cython.friso cimport (__FRISO_COMPLEX_MODE__,
                                          __FRISO_DETECT_MODE__,
                                          __FRISO_SIMPLE_MODE__,
                                          __LEX_CEM_WORDS__, __LEX_CJK_UNITS__,
                                          __LEX_CJK_WORDS__, __LEX_CN_DNAME1__,
                                          __LEX_CN_DNAME2__, __LEX_CN_LNA__,
                                          __LEX_CN_LNAME__, __LEX_CN_SNAME__,
                                          __LEX_ECM_WORDS__, __LEX_EN_WORDS__,
                                          __LEX_ENPUN_WORDS__,
                                          __LEX_NCSYN_WORDS__,
                                          __LEX_OTHER_WORDS__,
                                          __LEX_PUNC_WORDS__,
                                          __LEX_STOPWORDS__,
                                          __LEX_UNKNOW_WORDS__,
                                          free_string_split, friso_config_t,
                                          friso_dic_free, friso_dic_load,
                                          friso_dic_load_from_ifile,
                                          friso_dic_new, friso_dic_t,
                                          friso_free, friso_free_config,
                                          friso_free_task, friso_init_config,
                                          friso_init_from_ifile, friso_lex_t,
                                          friso_mode_t, friso_new,
                                          friso_new_config, friso_new_task,
                                          friso_set_mode, friso_set_text,
                                          friso_t, friso_task_t, friso_token_t,
                                          friso_version, fstring, lex_entry_t,
                                          new_string_split, string_split_next,
                                          string_split_reset,
                                          string_split_set_delimiter,
                                          string_split_set_source,
                                          string_split_t, uint_t)

# ----------------constants
MODE_SIMPLE = __FRISO_SIMPLE_MODE__
MODE_COMPLEX = __FRISO_COMPLEX_MODE__
MODE_DETECT = __FRISO_DETECT_MODE__

LEX_CJK_WORDS = __LEX_CJK_WORDS__
LEX_CJK_UNITS = __LEX_CJK_UNITS__
LEX_ECM_WORDS = __LEX_ECM_WORDS__    #english and chinese mixed words.
LEX_CEM_WORDS =__LEX_CEM_WORDS__    #chinese and english mixed words.
LEX_CN_LNAME = __LEX_CN_LNAME__
LEX_CN_SNAME = __LEX_CN_SNAME__
LEX_CN_DNAME1 = __LEX_CN_DNAME1__
LEX_CN_DNAME2 =__LEX_CN_DNAME2__
LEX_CN_LNA = __LEX_CN_LNA__
LEX_STOPWORDS = __LEX_STOPWORDS__
LEX_ENPUN_WORDS = __LEX_ENPUN_WORDS__
LEX_EN_WORDS = __LEX_EN_WORDS__
LEX_OTHER_WORDS = __LEX_OTHER_WORDS__
LEX_NCSYN_WORDS = __LEX_NCSYN_WORDS__
LEX_PUNC_WORDS = __LEX_PUNC_WORDS__      #punctuations
LEX_UNKNOW_WORDS = __LEX_UNKNOW_WORDS__      #unrecognized words.

# ---------------------

def version():
    return (<bytes> friso_version()).decode()

cdef inline bytes ensure_bytes(object o):
    if isinstance(o, unicode):
        return o.encode()
    elif isinstance(o, (bytes, bytearray)):
        return bytes(o)
    else:
        return o


class FrisoException(Exception):
    pass


@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class Friso:
    cdef:
        friso_t _friso
        bytes path_bytes
    def __cinit__(self):
        self._friso = friso_new()
        if not self._friso:
            raise FrisoException("new friso_t error")

    def __dealloc__(self):
        if self._friso:
            friso_free(self._friso)

    cpdef inline int init_from_ifile(self, Config config, object path) except -1:
        cdef int ret
        cdef bytes path_bytes = ensure_bytes(path)
        self.path_bytes = path_bytes
        cdef fstring path_ptr = <fstring> path_bytes
        # print(path_bytes[25:])
        with nogil:
            ret = friso_init_from_ifile(self._friso, config._config, path_ptr)
        if ret != 1:
            raise FrisoException("init error")
        return ret

    cpdef inline dic_load(self,Config config, friso_lex_t lex, object lexpath, uint_t length):
        cdef bytes f_bytes = ensure_bytes(lexpath)
        cdef fstring f_ptr = <fstring> f_bytes
        with nogil:
            friso_dic_load(self._friso,  config._config, lex ,f_ptr, length)

    cpdef inline dic_load_from_ifile(self,Config config, object lexpath, uint_t length):
        cdef bytes f_bytes = ensure_bytes(lexpath)
        cdef fstring f_ptr = <fstring> f_bytes
        with nogil:
            friso_dic_load_from_ifile(self._friso, config._config,f_ptr,length)


@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class Config:
    cdef friso_config_t _config
    def __cinit__(self):
        self._config = friso_new_config()
        if not self._config:
            raise FrisoException("new friso_config_t error")

    def __dealloc__(self):
        if self._config:
            friso_free_config(self._config)

    cpdef inline init(self):
        with nogil:
            friso_init_config(self._config)

    @property
    def max_len(self):
        return self._config.max_len
    @property
    def r_name(self):
        return self._config.r_name
    @property
    def mix_len(self):
        return self._config.mix_len
    @property
    def lna_len(self):
        return self._config.lna_len
    @property
    def add_syn(self):
        return self._config.add_syn
    @property
    def clr_stw(self):
        return self._config.clr_stw
    @property
    def keep_urec(self):
        return self._config.keep_urec
    @property
    def spx_out(self):
        return self._config.spx_out
    @property
    def en_sseg(self):
        return self._config.en_sseg
    @property
    def st_minl(self):
        return self._config.st_minl
    @property
    def nthreshold(self):
        return self._config.nthreshold
    @property
    def mode(self):
        return self._config.mode

    cpdef inline set_mode(self, friso_mode_t mod):
        friso_set_mode(self._config, mod)

    cpdef inline object next_token(self, Friso friso, Task task):
        cdef friso_token_t token = NULL
        with nogil:
            token = self._config.next_token(friso._friso, self._config, task._task)
        if token != NULL:
            return Token.from_ptr(token)
        else:
            return None

    cpdef inline object next_cjk(self, Friso friso, Task task):
        cdef lex_entry_t lex = NULL
        with nogil:
            lex = self._config.next_cjk(friso._friso, self._config,task._task)
        if lex != NULL:
            return Lex.from_ptr(lex)
        else:
            return None

@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class Task:
    cdef:
        friso_task_t _task
        const uint8_t [::1] text_view # keep a ref to that text
    def __cinit__(self):
        self._task = friso_new_task()
        if not self._task:
            raise FrisoException("new friso_task_t error")

    def __dealloc__(self):
        if self._task:
            friso_free_task(self._task)

    cpdef set_text(self, object text):
        cdef bytes text_bytes = ensure_bytes(text)
        self.text_view = text_bytes
        cdef fstring text_ptr = <fstring> text_bytes
        friso_set_text(self._task, text_ptr)

    cpdef set_bytes(self, const uint8_t[::1] text):
        self.text_view = text
        friso_set_text(self._task, <fstring>&text[0])


    @property
    def text(self):
        return (<bytes>self._task.text).decode()
    @property
    def idx(self):
        return self._task.idx
    @property
    def length(self):
        return self._task.length
    @property
    def bytes(self):
        return self._task.bytes
    @property
    def unicode(self):
        return self._task.unicode_
    @property
    def token(self):
        return Token.from_ptr(self._task.token)

@cython.freelist(8)
@cython.no_gc
@cython.final
@cython.internal
cdef class Token:
    cdef friso_token_t _token

    @staticmethod
    cdef inline Token from_ptr(friso_token_t token):
        cdef Token self = Token.__new__(Token)
        self._token = token
        return self

    @property
    def type(self):
        return self._token.type
    @property
    def length(self):
        return self._token.length

    @property
    def rlen(self):
        return self._token.rlen

    @property
    def pos(self):
        return self._token.pos

    @property
    def offset(self):
        return self._token.offset

    @property
    def word(self):
        return <bytes>self._token.word

@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class Lex:
    cdef lex_entry_t _lex
    @staticmethod
    cdef inline Lex from_ptr(lex_entry_t lex):
        cdef Lex self = Lex.__new__(Lex)
        self._lex = lex
        return self
    # todo: add more property

@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class StringSplit:
    """
    Split bytes
    """
    cdef:
        string_split_t _split
        const uint8_t[::1] delimiter
        const uint8_t[::1] source

    def __cinit__(self, const uint8_t[::1] delimiter, const uint8_t[::1] source):
        self.delimiter = delimiter
        self.source = source
        self._split =  new_string_split(<fstring>&delimiter[0],<fstring>&source[0])
        if not self._split:
            raise FrisoException("new string_split_t error")

    def __dealloc__(self):
        if self._split:
            free_string_split(self._split)

    cpdef inline reset(self, const uint8_t[::1] delimiter, const uint8_t[::1] source):
        self.delimiter = delimiter
        self.source = source
        string_split_reset( self._split, <fstring>&delimiter[0],<fstring>&source[0])

    cpdef  inline set_source(self,  const uint8_t[::1] source):
        self.source = source
        string_split_set_source(self._split, <fstring>&source[0])

    cpdef  inline set_delimiter(self,  const uint8_t[::1] delimiter):
        self.delimiter = delimiter
        string_split_set_delimiter(self._split, <fstring>&delimiter[0])

    cpdef inline split_next(self, uint8_t[::1] buffer):
        cdef fstring ret = NULL
        with nogil:
            ret =  string_split_next(self._split, <fstring>&buffer[0])
        if ret:
            return <bytes>ret
        else:
            return None

@cython.freelist(8)
@cython.no_gc
@cython.final
cdef class Dict:
    cdef friso_dic_t _dic
    def __cinit__(self):
        self._dic = friso_dic_new()
        if not self._dic:
            raise FrisoException("new friso_dic_t error")

    def __dealloc__(self):
        if self._dic:
            friso_dic_free(self._dic)
    #
    # def load_from_ifile(self, object path, int length):
    #     cdef bytes path_bytes = ensure_bytes(path)
    #     cdef fstring path_ptr = <fstring> path_bytes
    #     friso_dic_load_from_ifile(self._dic, path_ptr , __LENGTH__)