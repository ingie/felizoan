--[[
init.lua
generally bootstrap the system

create global libraries:
  3rd party:
    serpent
    strict
  local:
    logger

redirect global functions:
  print
  require
]]--

return function(ROOT)
  
  assert(ROOT,"ERROR: ROOT Must be passed to init.")
  local CONFIG = require(ROOT..'.etc.boot')

  local paths = 
  {
    boot      = ROOT..'.'..CONFIG.PATHS.BOOT,
    boot_lib  = ROOT..'.'..CONFIG.PATHS.BOOT_LIB,
    sys       = ROOT,
  }
  local paths_memo =
  {
    { name = "boot" },
    { name = "boot_lib" },
    { name = "sys" },
  }
  
  local init = {}
      
  _require = require
  local boot_lib = function(lib,n)
    if n then
      _require(paths.boot_lib..'.'..lib)
    else
    _G[lib] = _require(paths.boot_lib..'.'..lib)
    end
  end

  boot_lib('serpent')
  boot_lib('logger')
  boot_lib('fun')

  log       = logger.log
  log_entry = logger.log_entry
  log_exit  = logger.log_exit
  log_error = logger.log_error

  _print = print
  print = logger.print 
  
  _QUIT = function(reason)
    if rawget(_G,"love") then love.event.quit(reason) end
    log("QUIT",reason or "UNKNOWN REASON")
  end

  -- extended require - for debug / dependency / testing
  
  require = function(lib)
    assert(lib, string.format("MISSING LIB (%s)",tostring(lib)))
    logger.log_require(lib)
    return _require(paths.sys..'.'..lib)
  end

  -- strict mode
  boot_lib('strict',true)

  -- ------------------------------------------------------------------------
  -- get path of type [_t] or iterator of all -------------------------------
  init.getPath = function(_t)
    if _t then
      return paths[_t]
    end
    local i = 0
    return 
      function()
        i = i + 1
        if paths_memo[i] then
          return paths_memo[i].name, paths[paths_memo[i].name]
        end
      end
  end
  -- ------------------------------------------------------------------------
  -- get a config file
  init.load_config = function(_n)
    local ok, err = pcall(
      function()
        return require('.etc.'..tostring(_n))
      end
    )
    return ok or false, err
  end
  
  
  return init
  
end