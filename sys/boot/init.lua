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

serpent   = require 'sys.boot.serpent'

-- debug/logging
logger    = require 'sys.boot.logger'

log       = logger.log
log_entry = logger.log_entry
log_exit  = logger.log_exit
log_error = logger.log_error

_print = print
print = logger.print 

-- extended require - for debug / dependency / testing
_require = require
require = function(...)
  local libs = {...}
  assert(#libs > 0, "MISSING LIB")
  logger.log_require(libs[1])
  return _require(libs[1])
end

-- strict mode
require 'sys.boot.strict'

return