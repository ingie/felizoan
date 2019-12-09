local compiler = {}

--[[

  data.
    src.objects.
    cache.
      drawables.
        src = src-object-index,
        updater = updateable-index,
      updateables.
        src = src-object-index,
        drawer = drawable-index,
    
]]--

local force_types = {
  momentum = {
    acts_upon = "position",
    expressed_as = "velocity",
    occurs = { on_tick = true },
    axes = {x = true, y = true, z = true},
  },
  gravity = {
    acts_upon = "position",
    expressed_as = "weight",
    occurs = { on_tick = true },
    axes = {x = true, y = true, z = true},
  }  
}
      
compiler.compile = function(lib,data,params)
  log_entry("utils.compile")
  local drawables = {}
  local updateables = {}
  for k,v in pairs(data.src) do
    log(string.format("Compiling object: %s",v.name))
    
    local draw_key = #drawables+1
    drawables[draw_key] = {
      mass = v.mass,      
      scale = v.scale,
      rotation = v.rotation,
      colour = v.colour, 
      draw = data.sys.types[v.type].draw_gen(lib,data,v)
    }
    
    if v.forces then
      local draw_object = drawables[draw_key]
      for fx,fv in pairs(v.forces) do
         log(fx)
        if force_types[fx] then         
          draw_object[force_types[fx].expressed_as] = draw_object[force_types[fx].expressed_as] or {}
          draw_object[force_types[fx].acts_upon] = draw_object[force_types[fx].acts_upon] or {}
          for ak,av in pairs(v[force_types[fx].acts_upon]) do
            if force_types[fx].axes[ak] then
              draw_object[force_types[fx].expressed_as][ak] = 
                draw_object[force_types[fx].expressed_as][ak] 
                  and ( draw_object[force_types[fx].expressed_as][ak] + v.forces[fx].initial[ak] )
                  or v.forces[fx].initial[ak]
              draw_object[force_types[fx].acts_upon][ak] = v[force_types[fx].acts_upon][ak]    
            end
          end
        end
      end
      
      updateables[#updateables+1] = {
        mass = v.mass,
        update = function(dt) -- data.sys.types[v.type].update_gen(lib,v)

          -- for each axis apply expressed_force[axis] to acted_upon[axis]
          for fx,fv in pairs(v.forces) do
            for axn,axv in pairs(draw_object[force_types[fx].expressed_as]) do
              
              --apply
--              log(axn, force_types[fx].acts_upon)
--              print(draw_object)
              draw_object[force_types[fx].acts_upon][axn] = 
                draw_object[force_types[fx].acts_upon][axn] + dt * axv -- / ( v.mass * 2 )
                
              -- limit
              if draw_object[force_types[fx].acts_upon][axn] > 1 or
                draw_object[force_types[fx].acts_upon][axn] < 0 then
                
                -- "bounce"
                draw_object[force_types[fx].expressed_as][axn] = 
                  -draw_object[force_types[fx].expressed_as][axn]
                draw_object[force_types[fx].acts_upon][axn] = 
                  draw_object[force_types[fx].acts_upon][axn] + 
                  dt * draw_object[force_types[fx].expressed_as][axn] -- / ( v.mass * 2 )
              end
            end
          end
        end
      }      
      
    end
    
end
  data.cache.drawables = drawables
  data.cache.updateables = updateables
  log_exit("utils.compile")
  return data
end

return compiler
