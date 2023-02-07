--- Simplistic object templating and inheritance
-- @see https://github.com/DataDink/extends.lua#README.md
local extend = (function() 
  local INIT_NAME="initialize";
  local DESC_NAME="inherits";
  local PROP_NAME="properties";
  local META_NAME="metatable";
  local lib; lib={
    [INIT_NAME]=function(prototype, ...)
      local definition = getmetatable(prototype);
      if ((definition and definition.__call)~=lib[INIT_NAME]) then return definition; end
      local metatable = {__index=lib[INIT_NAME](prototype, ...)};
      for k,v in pairs(definition[META_NAME]) do rawset(metatable,k,v); end
      local instance = setmetatable({}, metatable);
      for k,v in pairs(definition[PROP_NAME]) do rawset(instance,k,v); end
      if (definition[INIT_NAME]) then definition[INIT_NAME](instance, ...); end
      return instance;
    end,
    [DESC_NAME]=function(instance, template)
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
        [DESC_NAME]=lib[DESC_NAME],
      }, {
        [PROP_NAME]={},
        [META_NAME]={},
        __call=lib[INIT_NAME],
        __index=base,
      });
      for k,v in pairs(template) do
        if (k==INIT_NAME and type(v)=="function") then getmetatable(prototype)[k] = v;
        elseif (k:sub(1,2)=="__") then getmetatable(prototype)[META_NAME][k]=v;
        elseif (type(v)=="function") then rawset(prototype, k, v);
        else getmetatable(prototype)[PROP_NAME][k]=v; end
      end
    end
  }); 
end)();
return extend;
