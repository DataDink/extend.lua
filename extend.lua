--- Simplistic object templating and inheritance
-- @see https://github.com/DataDink/extends.lua#README.md
local extend = (function() 
  local INIT_MBR_NAME="initialize";
  local DESC_MBR_NAME="inherits";
  local PROP_MBR_NAME="properties";
  local META_MBR_NAME="metatable";
  local lib; lib={
    [INIT_MBR_NAME]=function(prototype, ...)
      local definition = getmetatable(prototype);
      if ((definition and definition.__call)~=lib[INIT_MBR_NAME]) then return setmetatable({},{__index=prototype}); end
      local instance = lib[INIT_MBR_NAME](prototype, ...);
      for k,v in pairs(definition[PROP_MBR_NAME]) do rawset(instance,k,v); end
      local metatable = {__index=prototype};
      for k,v in pairs(definition[META_MBR_NAME]) do rawset(metatable,k,v); end
      setmetatable(instance, metatable);
      if (definition[INIT_MBR_NAME]) then definition[INIT_MBR_NAME](instance, ...); end
      return instance;
    end,
    [DESC_MBR_NAME]=function(instance, template)
      instance = getmetatable(instance);
      while (instance and instance.__index) do
        if (instance==template) then return true; end
        instance = getmetatable(instance.__index);
      end
      return false;
    end,
  };
  return setmetatable(lib, {
    __call=function(self, base, template)
      base = base or {}; template = template or {};
      local prototype = setmetatable({
        [DESC_MBR_NAME]=lib[DESC_MBR_NAME],
      }, {
        [PROP_MBR_NAME]={},
        [META_MBR_NAME]={},
        __call=lib[INIT_MBR_NAME],
        __index=base,
      });
      for k,v in pairs(template) do
        if (k==INIT_MBR_NAME and type(v)=="function") then getmetatable(prototype)[k] = v;
        elseif (k:sub(1,2)=="__") then getmetatable(prototype)[META_MBR_NAME][k]=v;
        elseif (type(v)=="function") then rawset(prototype, k, v);
        else getmetatable(prototype)[PROP_MBR_NAME][k]=v; end
      end
    end
  }); 
end)();
return extend;
