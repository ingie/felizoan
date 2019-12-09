serpent = require 'boot.serpent' -- ?? move into logger as local
logger = require 'boot.logger'
log = logger.log
log_entry = logger.log_entry
log_exit = logger.log_exit
log_error = logger.log_error

_print = print
print = logger.print 


_require = require

require = function(...)
  local libs = {...}
  assert(#libs > 0, "MISSING LIB")
  logger.log_require(libs[1])
  return _require(libs[1])
end

require 'boot.strict'