local version = setmetatable({
  major = 0,
  minor = 1,
  patch = 0,
  --suffix = ""
}, {
  __tostring = function(t)
    return string.format("%d.%d.%d%s", t.major, t.minor, t.patch,
                         t.suffix and t.suffix or "")
  end
})

return {
  _NAME = "cdn",
  _VERSION = tostring(version),
  _VERSION_TABLE = version,

  -- third-party dependencies' required version, as they would be specified
  -- to lua-version's `set()` in the form {from, to}
  _DEPENDENCIES = {
    nginx = {"1.12.1"},
  }
}
