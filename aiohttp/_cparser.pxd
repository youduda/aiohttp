from libc.stdint cimport uint16_t, uint32_t, uint64_t


cdef extern from "../vendor/llhttp/build/llhttp.h":
    ctypedef int (*llhttp_data_cb) (llhttp_t*,
                                    const char *at,
                                    size_t length) except -1

    ctypedef int (*llhttp_cb) (llhttp_t*) except -1

    struct llhttp_t:
        # internal structure, may be a subject of changes
        int32_t _index
        void* _span_pos0
        void* _span_cb0
        int32_t error
        const char* reason
        const char* error_pos
        void* data
        void* _current
        uint64_t content_length
        uint8_t type
        uint8_t method
        uint8_t http_major
        uint8_t http_minor
        uint8_t header_state
        uint16_t flags
        uint8_t upgrade
        uint16_t status_code
        uint8_t finish
        void* settings

    struct llhttp_settings_t:
        # /* Possible return values 0, -1, `HPE_PAUSED` */
        llhttp_cb      on_message_begin

        llhttp_data_cb on_url
        llhttp_data_cb on_status
        llhttp_data_cb on_header_field
        llhttp_data_cb on_header_value

        # /* Possible return values:
        # * 0  - Proceed normally
        # * 1  - Assume that request/response has no body, and proceed to parsing the
        # *      next message
        # * 2  - Assume absence of body (as above) and make `llhttp_execute()` return
        # *      `HPE_PAUSED_UPGRADE`
        # * -1 - Error
        # * `HPE_PAUSED`
        # */
        llhttp_cb      on_headers_complete

        llhttp_data_cb on_body

        # /* Possible return values 0, -1, `HPE_PAUSED` */
        llhttp_cb      on_message_complete

        # /* When on_chunk_header is called, the current chunk length is stored
        # * in parser->content_length.
        # * Possible return values 0, -1, `HPE_PAUSED`
        # */
        llhttp_cb      on_chunk_header
        llhttp_cb      on_chunk_complete

    enum llhttp_type_t:
        HTTP_BOTH = 0
        HTTP_REQUEST = 1
        HTTP_RESPONSE = 2

    enum llhttp_errno:
        HPE_OK = 0
        HPE_INTERNAL = 1
        HPE_STRICT = 2
        HPE_LF_EXPECTED = 3
        HPE_UNEXPECTED_CONTENT_LENGTH = 4
        HPE_CLOSED_CONNECTION = 5
        HPE_INVALID_METHOD = 6
        HPE_INVALID_URL = 7
        HPE_INVALID_CONSTANT = 8
        HPE_INVALID_VERSION = 9
        HPE_INVALID_HEADER_TOKEN = 10
        HPE_INVALID_CONTENT_LENGTH = 11
        HPE_INVALID_CHUNK_SIZE = 12
        HPE_INVALID_STATUS = 13
        HPE_INVALID_EOF_STATE = 14
        HPE_INVALID_TRANSFER_ENCODING = 15
        HPE_CB_MESSAGE_BEGIN = 16
        HPE_CB_HEADERS_COMPLETE = 17
        HPE_CB_MESSAGE_COMPLETE = 18
        HPE_CB_CHUNK_HEADER = 19
        HPE_CB_CHUNK_COMPLETE = 20
        HPE_PAUSED = 21
        HPE_PAUSED_UPGRADE = 22
        HPE_USER = 23

    enum llhttp_flags_t:
        F_CONNECTION_KEEP_ALIVE = 0x1
        F_CONNECTION_CLOSE = 0x2
        F_CONNECTION_UPGRADE = 0x4
        F_CHUNKED = 0x8
        F_UPGRADE = 0x10
        F_CONTENT_LENGTH = 0x20
        F_SKIPBODY = 0x40
        F_TRAILING = 0x80
        F_LENIENT = 0x100
        F_TRANSFER_ENCODING = 0x200

    enum llhttp_finish_t:
        HTTP_FINISH_SAFE = 0
        HTTP_FINISH_SAFE_WITH_CB = 1
        HTTP_FINISH_UNSAFE = 2

    enum llhttp_method_t:
        HTTP_DELETE = 0
        HTTP_GET = 1
        HTTP_HEAD = 2
        HTTP_POST = 3
        HTTP_PUT = 4
        HTTP_CONNECT = 5
        HTTP_OPTIONS = 6
        HTTP_TRACE = 7
        HTTP_COPY = 8
        HTTP_LOCK = 9
        HTTP_MKCOL = 10
        HTTP_MOVE = 11
        HTTP_PROPFIND = 12
        HTTP_PROPPATCH = 13
        HTTP_SEARCH = 14
        HTTP_UNLOCK = 15
        HTTP_BIND = 16
        HTTP_REBIND = 17
        HTTP_UNBIND = 18
        HTTP_ACL = 19
        HTTP_REPORT = 20
        HTTP_MKACTIVITY = 21
        HTTP_CHECKOUT = 22
        HTTP_MERGE = 23
        HTTP_MSEARCH = 24
        HTTP_NOTIFY = 25
        HTTP_SUBSCRIBE = 26
        HTTP_UNSUBSCRIBE = 27
        HTTP_PATCH = 28
        HTTP_PURGE = 29
        HTTP_MKCALENDAR = 30
        HTTP_LINK = 31
        HTTP_UNLINK = 32
        HTTP_SOURCE = 33
        HTTP_PRI = 34

    void llhttp_init(llhttp_t *parser, llhttp_type_t type,
                     const llhttp_settings_t* settings)

    void llhttp_settings_init(llhttp_settings_t *settings)

    llhttp_errno_t llhttp_execute(llhttp_t *parser,
                                  const char *data,
                                  size_t len)

    llhttp_errno_t llhttp_finish(llhttp_t* parser)

    int llhttp_message_needs_eof(const llhttp_t* parser)
    int llhttp_should_keep_alive(const llhttp_t* parser)

    void llhttp_pause(llhttp_t* parser)
    void llhttp_resume(llhttp_t* parser)
    void llhttp_resume_after_upgrade(llhttp_t* parser)

    llhttp_errno_t llhttp_get_errno(const llhttp_t* parser)
    const char* llhttp_get_error_reason(const llhttp_t* parser)
    void llhttp_set_error_reason(llhttp_t* parser, const char* reason)
    const char* llhttp_get_error_pos(const llhttp_t* parser)
    const char* llhttp_errno_name(llhttp_errno_t err)
    const char* llhttp_method_name(llhttp_method_t method)

    void llhttp_set_lenient(llhttp_t* parser, int enabled)
