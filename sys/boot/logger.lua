
--  ---------------------------------------------------------------------------------------------------  
local logger = 
{
  _ID = {
    _NAME     = "Logger",
    _VERSION  = "1.0",
    _DESC     = "System Logger",
    _REQUIRES = nil,
  },
  CONFIG = {
    I_CHAR = " ",
  },
  _current_indent = 0,
  logging = true,
  logging_print = true,
  logging_require = true,
}

local ESC = string.char(27)
local ANSI = function(SEQ) return ESC.."["..SEQ.."m" end

logger.log_indent = function(t)
  return string.rep(logger.CONFIG.I_CHAR or " ",logger._current_indent)..tostring(t) 
end


local rep_dash = function(s,r) return string.rep(s or "-",r or 30) end

local log_header = function(log,char, rep, brac)
  local dashes = rep_dash(char, (rep or 50.5) - math.floor(string.len(log) / 2)  )
  local _h = dashes.." "..(brac or "[").." "..tostring(log).." "..(brac or "]").." "..dashes
  return _h
end


local log_date = function() return os.date() end

local log_writer = io.stdout
local log_file;


--print(log_file:close())
--io.stdout:setvbuf("no")
local log_write = function(...)
  if log_file then
    log_file:write(...)
    log_file:flush()
  end
  log_writer:write(...) 
end

-- local log_nl = function(e) log_write(string.format("    %s :\n", (e and "/" or "\\") )) return true end

local flatten;
flatten = function(_t)
  assert(type(_t) == "table", "_t not table (flatten)")
  local _r = ""
  local _s = ",\t"
  for _,_v in pairs(_t) do
    _r = _r .. (_r == "" and "" or _s) .. (type(_v) == "table" and flatten(_v) or tostring(_v))
  end
  return _r
end

local caller_info = function(_level)
  if not debug or not debug.getinfo then return "UNKNOWN",0 end
  local i = debug.getinfo(_level,"Sl")
  local _file, _line = i.short_src and i.short_src or "UNKNOWN", i.currentline and i.currentline or 0
  return string.format("[%20s : %4d ]", string.sub(_file,-20), _line)
end

local write_io = function(_type,_text,_ci)
  local _tt = string.sub( (_type and _type or "").."      " ,1,6) 
  log_write(string.format( _tt ..": %20s %s\t%s\n", log_date(), _ci or caller_info(5) or "",_text )..ANSI("0;37;"))  
end

local write_trace = function(_mode, _text, _ci)
  if not logger.logging then return end
  write_io( _mode, ANSI("36;1").. _text, _ci )  
  return true
end

local write_error = function(...)
  if not logger.logging then return end
  local prel = string.format("%s",tostring(select(1,...)))
  local endl = tostring((select(2,...) and ( " : "..select(2,...) ) or ""))
  
  local output = ANSI("31;1;").. log_header(prel,"*",20,"") ..endl
  
  write_io( "ERROR",  output)
end

local write_log = function(...)
  -- _print(...)
  if not logger.logging then return end
  local prel = string.format("%s",tostring(select(1,...)))
  local endl = tostring((select(2,...) and select(2,...) or ""))
  
  local output = ANSI("36;").. log_header(prel,"",0,"")..endl
  
  write_io( "LOG", logger.log_indent(output))
end

local write_require = function(...)
  if not logger.logging_require then return end
  local prel = string.format("%s",tostring(select(1,...)))
  local endl = tostring((select(2,...) and select(2,...) or ""))
  local output = ANSI("32;")..log_header( prel ,"" , 0 ,"")..endl
  write_io( "REQ",  output)
end

local write_debug = function(...)
  if not logger.logging_debug then return end
  write_io( "DEBUG", ANSI("30;1;")..flatten({...}), caller_info(5) )
end

local no_print = function(...)
  if not logger.logging_print then return end
  local args = {...}
  local output = serpent.line( args, { numformat = "%d", comment = false, nocode = true } )
  write_io( "PRINT", output )   
end

logger.print = no_print
logger.debug = write_debug


logger.log_file     = function(filename) 
  log_file = io.open(filename,"w") 
  return log_file 
end

logger.log          = function(...) return write_log(...)                   end
logger.log_error    = function(...) return write_error(...)  end
logger.log_entry    = function(log) 
  logger._current_indent = logger._current_indent + 1
  --return log_nl() and write_trace("->",log_header(log,""), caller_info(4))  
  return write_trace("->",log_header(log,""), caller_info(4))  
end
logger.log_exit     = function(log) 
  logger._current_indent = logger._current_indent - 1
  return write_trace("<-",log_header(log,""), caller_info(4)) -- and log_nl(true)  
end
logger.log_require  = write_require

write_trace("INIT", "Logger Loaded.")

return logger