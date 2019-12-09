------------------------------------------------------------------------
--[[

]]--
------------------------------------------------------------------------

-- boot/init -----------------------------------------------------------
------------------------------------------------------------------------
require 'boot.init'

-- boot complete -------------------------------------------------------
------------------------------------------------------------------------


-- load common libraries -----------------------------------------------
------------------------------------------------------------------------
local lib = require 'lib._lib'

-- initialise data -----------------------------------------------------
------------------------------------------------------------------------
local data = lib.compiler.compile(lib,require 'data._data')

-- run -----------------------------------------------------------------
------------------------------------------------------------------------
lib.engine.run(lib,data)
------------------------------------------------------------------------