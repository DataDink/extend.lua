--- Simplistic object templating and inheritance
-- @see https://github.com/DataDink/extends.lua#README.md
local INIT_FUNC_NAME = "initialize";
local extend; extend = setmetatable({
  initialize=function(prototype, ...)
    local config = getmetatable(prototype);
    if ((config and config.__call)~=extend.initialize) then local meta = {}; return setmetatable({},meta), meta; end
    local new, meta = extend.initialize(getmetatable(config.__index).__index, ...);
    for k,v in pairs(config.instance) do rawset(new,k,v); end
    for k,v in pairs(config.meta) do rawset(meta,k,v); end
    meta.__index=config.__index;
    if (config.meta[INIT_FUNC_NAME]) then config.meta[INIT_FUNC_NAME](new, ...); end
    return new, meta;
  end,
  assign=function(instance, static, meta, key, value)
    if (key==INIT_FUNC_NAME) then rawset(meta, key, nil); end
    if (key:sub(1,2)=="__") then rawset(meta, key, value);
    elseif (key==INIT_FUNC_NAME and type(value)=="function") then rawset(meta, key, value); rawset(instance, key, nil); rawset(static, key, nil);
    elseif (type(value)=="function") then rawset(static, key, value); rawset(instance, key, nil);
    elseif (type(value)=="table") then rawset(static, key, value); rawset(instance, key, nil);
    else rawset(instance, key, value); rawset(static, key, nil); end
  end,
  ancestors=function(prototype, instance)
    local proto, inst = getmetatable(prototype), getmetatable(instance);
    if ((proto and proto.__index)==nil) then return false; end
    while (inst~=nil) do
      if (inst.__index==proto.__index) then return true; end
      inst = getmetatable(inst.__index);
    end
    return false;
  end,
}, {
  __call=function(self, base, template)
    if (type(base)~="table") then error("base must be a table: ("..type(base)..")"..tostring(base)); end
    if (template~=nil and type(template)~="table") then error("template must be a table or nil: ("..type(template)..")"..tostring(template)); end
    local config; config={
      meta={}, 
      instance={},
      __call=extend.initialize,
      __index=setmetatable({}, {__index=base}),
      __newindex=function(self,key,value) extend.assign(config.instance, config.__index, config.meta, key, value); end,
    };
    for k,v in pairs(template or {}) do extend.assign(config.instance, config.__index, config.meta, k, v); end
    return setmetatable({ancestors=extend.ancestors}, config);
  end
});
return extend;
