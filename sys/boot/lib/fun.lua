--
-- various functional style programming helpers
-- 

-- begin library
--

local functional = { 
  _ID = {
  _VERSION = "0.1",
  _NAME = "Functional",
  _DESC = "Function programming helpers",
  _REQUIRES = { },
  },  
}

-- from https://pragprog.com/magazines/2013-05/a-functional-introduction-to-lua
functional.map = function (things, fn)
    local mapped = {}
    for index, thing in pairs(things) do
        mapped[index] = fn(thing)
    end
    return mapped
end

-- each
--
functional.each = function(things, fn)
    for i, thing in ipairs(things) do
        fn(thing, i)
    end
end

-- filter
--
functional.filter = function (things, fn)
  local filtered = {}
  local index = {}
  functional.each(things, function(thing, thingdex)
      if fn(thing) then
          table.insert(filtered, thing)
          table.insert(index,thingdex)
      else
        --print("nope",thing.name)
      end 
  end)
  return filtered, index
end

-- cons
--
functional.cons = function(things, ...)
    local all = {}
    functional.each({...}, function(t)
        table.insert(all, t)
    end)
    functional.each(things, function(t)
        table.insert(all, t)
    end)
    return all
end
--

functional.flatten = function(t) end  
functional.flatten = function(t)
  local ret = {}
  for _, v in ipairs(t) do
    if type(v) == 'table' then
      for _, fv in ipairs(functional.flatten(v)) do
        ret[#ret + 1] = fv
      end
    else
      ret[#ret + 1] = v
    end
  end
  return ret
end
--

functional.curryo = function(func, num_args)
  num_args = num_args or debug.getinfo(func, "u").nparams
  if num_args < 2 then return func end
  local function helper(argtrace, n)
    if n < 1 then
      return func(unpack(functional.flatten(argtrace)))
    else
      return function (...)
        return helper({argtrace, ...}, n - select("#", ...))
      end
    end
  end
  return helper({}, num_args)
end
--

-- reverse(...) : take some tuple and return a tuple of	elements in reverse order
--
-- e.g.	"reverse(1,2,3)" returns 3,2,1
functional.reverse = function(...)
   
   --reverse args by building a function to do it, similar to the unpack() example
   local function reverse_h(acc, v, ...)
      if 0 == select('#', ...) then
      	 return v, acc()
      else
         return reverse_h(function () return v, acc() end, ...)
      end
   end
   
   -- initial acc is the end of	the list
   return reverse_h(function () return end, ...)
end

-- Lua implementation of the curry function
-- Developed by tinylittlelife.org
-- released under the WTFPL (http://sam.zoy.org/wtfpl/)
 
-- curry(func, num_args) : take a function requiring a tuple for num_args arguments
--              and turn it into a series of 1-argument functions
-- e.g.: you have a function dosomething(a, b, c)
--       curried_dosomething = curry(dosomething, 3) -- we want to curry 3 arguments
--       curried_dosomething (a1) (b1) (c1)  -- returns the result of dosomething(a1, b1, c1)
--       partial_dosomething1 = curried_dosomething (a_value) -- returns a function
--       partial_dosomething2 = partial_dosomething1 (b_value) -- returns a function
--       partial_dosomething2 (c_value) -- returns the result of dosomething(a_value, b_value, c_value)
functional.curry = function(func, num_args)
  
   -- currying 2-argument functions seems to be the most popular application
   num_args = num_args or 2
  
   -- helper
   local function curry_h(argtrace, n)
      if 0 == n then
      	 -- reverse argument list and call function
         return func(functional.reverse(argtrace()))
      else
         -- "push" argument (by building a wrapper function) and decrement n
         return function (onearg)
                   return curry_h(function () return onearg, argtrace() end, n - 1)
                end
      end
   end
   
   -- no sense currying for 1 arg or less
   if num_args > 1 then
      return curry_h(function () return end, num_args)
   else
      return func
   end
end
--

--  
-- end of library
--  
  




return functional
