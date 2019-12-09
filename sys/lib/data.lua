-- TODO: Document me!

local data = {}

data.crud = function(_t,params)
  
  local i = {}
  
  local dmt = { 
    __index = function(k,v)
      print("dmti",k,v)
    end,
    __newindex = function(t,k,v)
      print("dmtni",t, k,v)
    end    
  }
  
  local _database = setmetatable(_t or {}, dmt)
  
  local imt = 
  { 
    __index = function(t,k) 
      local dif = debug.getinfo(2)
      error(string.format("INDEX CALLED (%s:%d)",dif.short_src,dif.currentline))
    end,
    __newindex = function(t,k,v) 
      local dif = debug.getinfo(2)
      error(string.format("NEWINDEX CALLED (%s:%d)",dif.short_src,dif.currentline))
    end,
    __call = function(_,k) 
      local f = string.lower(tostring(k[1]))
      assert(i[f],string.format("Invalid function (%s)",f))
      return i[f](select(2,unpack(k)))
    end,
    __tostring = function(_t) 
      return serpent.line(_database, {comment=false},{nocode=true}) 
    end 
  } 
  
  local crud_table = setmetatable( {}, imt )

  -- ------------------------------------------------------------------------
  -- create
  
  i.create = function(key,value)
    assert(not _database[key],string.format("Table already exists ('%s').",key))
    rawset(_database,key,value)
    return crud_table
  end
  
  -- ------------------------------------------------------------------------
  -- insert
  
  i.insert = function(t_key, value)
    assert(_database[t_key],string.format("Table must exist ('%s').",t_key))
    local tab = rawget(_database,t_key)
    tab[#tab+1] = value
    return crud_table
  end
  
  -- ------------------------------------------------------------------------
  -- read
  
  i.read = function(key)
    -- TODO: this gives access to the table, which is not desired
    return setmetatable(rawget(_database,key),dmt)
  end
  
  -- ------------------------------------------------------------------------
  -- update
  i.update = function(...)
    local opt = {...}
    assert(_database[opt[1] or "________"], string.format("Table not found (%s)",tostring(opt[1])))
    assert(#opt == 3, string.format("Missing criteria for (%s)",tostring(opt[1])))
    
    local tab = opt[1]
    local db_tab = _database[tab]
    local filter = opt[2]
    local set = opt[3]
    local crits = {}
    
    -- split each filter criterion into its own table row
    for k,v in pairs(filter) do
      crits[#crits+1] = { field = k, value = v }
    end
    
    -- loop through all records, critera per record, field per criterion
    local valid = {}
    for record,fields in ipairs(db_tab) do
      local crit_remain = #crits
      for cx,crit in ipairs(crits) do
        for field_name, field_value in pairs(fields) do
          if field_name == crit.field then
            if field_value == crit.value then
              crit_remain = crit_remain - 1
            end
          end
        end
        -- if no criteria remain, we've found a valid record
        if crit_remain == 0 then
          valid[#valid+1] = { record = record }
        end
      end
    end
    
    -- update every valid record
    for k,v in ipairs(valid) do
      for set_field,set_val in pairs(set) do
        db_tab[v.record][set_field] = set_val
      end
    end
    
    -- return the table manager
    return crud_table
  end
  
  -- ------------------------------------------------------------------------
  -- delete
  

  
  return crud_table
 
end



return data
