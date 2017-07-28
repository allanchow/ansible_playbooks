local ffi = require "ffi"

local C          = ffi.C
local ffi_new    = ffi.new
local ffi_str    = ffi.string

ffi.cdef[[
typedef unsigned char u_char;

int RAND_bytes(u_char *buf, int num);

unsigned long ERR_get_error(void);
void ERR_load_crypto_strings(void);
void ERR_free_strings(void);

const char *ERR_reason_error_string(unsigned long e);

int open(const char * filename, int flags, int mode);
size_t read(int fd, void *buf, size_t count);
int close(int fd);
char *strerror(int errnum);
]]

local _M = {}


local get_rand_bytes

do
  local ngx_log = ngx.log
  local WARN    = ngx.WARN

  local O_RDONLY = (require "lua_system_constants").O_RDONLY()
  local bytes_buf_t = ffi.typeof "char[?]"

  local function urandom_bytes(buf, size)
    local fd = C.open("/dev/urandom", O_RDONLY, 0) -- mode is ignored
    if fd < 0 then
      ngx_log(WARN, "Error opening random fd: ", ffi_str(C.strerror(ffi.errno())))

      return false
    end

    local res = C.read(fd, buf, size)
    if res <= 0 then
      ngx_log(WARN, "Error reading from urandom: ", ffi_str(C.strerror(ffi.errno())))

      return false
    end

    if C.close(fd) ~= 0 then
      ngx_log(WARN, "Error closing urandom: ", ffi_str(C.strerror(ffi.errno())))
    end

    return true
  end

  -- try to get n_bytes of CSPRNG data, first via /dev/urandom,
  -- and then falling back to OpenSSL if necessary
  get_rand_bytes = function(n_bytes, urandom)
    local buf = ffi_new(bytes_buf_t, n_bytes)

    -- only read from urandom if we were explicitly asked
    if urandom then
      local rc = urandom_bytes(buf, n_bytes)

      -- if the read of urandom was successful, we returned true
      -- and buf is filled with our bytes, so return it as a string
      if rc then
        return ffi_str(buf, n_bytes)
      end
    end

    if C.RAND_bytes(buf, n_bytes) == 0 then
      -- get error code
      local err_code = C.ERR_get_error()
      if err_code == 0 then
        return nil, "could not get SSL error code from the queue"
      end

      -- get human-readable error string
      C.ERR_load_crypto_strings()
      local err = C.ERR_reason_error_string(err_code)
      C.ERR_free_strings()

      return nil, "could not get random bytes (" ..
                  "reason:" .. ffi_str(err) .. ") "
    end

    return ffi_str(buf, n_bytes)
  end

  _M.get_rand_bytes = get_rand_bytes
end

return _M
