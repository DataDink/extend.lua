local unit = require("luaunit");
local extend = require("extend");

function testNoArgs()
  local prototype = extend();
  unit.assertEquals(type(prototype), "table");
  unit.assertEquals(type(getmetatable(prototype)), "table");
  unit.assertEquals(type(getmetatable(prototype).__index), "table");
  unit.assertIs(getmetatable(prototype).__call, extend.initialize);
  unit.assertEquals(type(getmetatable(prototype).properties), "table");
  unit.assertEquals(type(getmetatable(prototype).metatable), "table");
  unit.assertEquals(type(getmetatable(prototype).initialize), "nil");
end

function testBaseOnly()
  local base = {};
  local prototype = extend(base);
  unit.assertIs(getmetatable(prototype).__index, base);
end

function testInitializerExists()
  local initializer = function() end;
  local prototype = extend({}, {initialize = initializer});
  unit.assertEquals(type(getmetatable(prototype).initialize), "function");
end

function testPrefixToMeta()
  local prototype = extend({}, {__foo = "bar"});
  unit.assertEquals(getmetatable(prototype).metatable.__foo, "bar");
end

function testFunctionToStatic()
  local prototype = extend({}, {foo = function() end});
  unit.assertEquals(type(rawget(prototype, "foo")), "function");
end

function testStringToProps()
  local prototype = extend({}, {foo = "bar"});
  unit.assertEquals(getmetatable(prototype).properties.foo, "bar");
end

function testTableToProps()
  local prototype = extend({}, {foo = {}});
  unit.assertEquals(getmetatable(prototype).properties.foo, {});
end

function testNumberToProps()
  local prototype = extend({}, {foo = 1});
  unit.assertEquals(getmetatable(prototype).properties.foo, 1);
end

function testBooleanToProps()
  local prototype = extend({}, {foo = true});
  unit.assertEquals(getmetatable(prototype).properties.foo, true);
end

function testAncestorsNoArgs() 
  unit.assertIsFalse(extend.ancestors()); 
end

function testAncestorsNilInstance() 
  unit.assertIsFalse(extend.ancestors({}, nil)); 
end

function testAncestorsNilPrototype() 
  unit.assertIsFalse(extend.ancestors(nil, nil)); 
end

function testAncestorsStringInstance() 
  unit.assertIsFalse(extend.ancestors({}, "foo")); 
end

function testAncestorsStringPrototype() 
  local value="foo";
  unit.assertIsTrue(extend.ancestors(value, value)); 
end

function testAncestorsNumberInstance() 
  unit.assertIsFalse(extend.ancestors({}, 42)); 
end

function testAncestorsNumberPrototype() 
  local value=42;
  unit.assertIsFalse(extend.ancestors(value, value)); 
end

function testAncestorsBooleanInstance() 
  unit.assertIsFalse(extend.ancestors({}, true)); 
end

function testAncestorsBooleanPrototype() 
  local value=true;
  unit.assertIsFalse(extend.ancestors(value, value)); 
end

function testAncestorsTables() 
  local value={};
  unit.assertIsFalse(extend.ancestors(value, value)); 
end

function testAncestorsNoMeta() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsFalse(extend.ancestors(proto, {})); 
end

function testAncestorsNoIndex() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsFalse(extend.ancestors(proto, setmetatable({}, {}))); 
end

function testAncestorsNoMatch() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsFalse(extend.ancestors(proto, setmetatable({}, {__index={}}))); 
end

function testAncestorsNoMatchNested() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsFalse(extend.ancestors(proto, setmetatable({}, {__index=setmetatable({}, {__index={}})}))); 
end

function testAncestorsMatchZeroDeep() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsFalse(extend.ancestors(proto, index)); 
end

function testAncestorsMatchOneDeep() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsTrue(extend.ancestors(proto, setmetatable({}, {__index=index}))); 
end

function testAncestorsMatchTwoDeep() 
  local index={};
  local proto=setmetatable({}, {__index=index});
  unit.assertIsTrue(extend.ancestors(proto, setmetatable({}, {__index=setmetatable({}, {__index=index})}))); 
end

function testExtendNoArgs() unit.assertError(function() extend(); end); end

function testExtendStringBase() unit.assertError(function() extend("foo"); end); end

function testExtendNumberBase() unit.assertError(function() extend(42); end); end

function testExtendFunctionBase() unit.assertError(function() extend(function() end); end); end

function testExtendBooleanBase() unit.assertError(function() extend(true); end); end

function testExtendOnlyBase() unit.assertEquals(type(extend({})), "table"); end

function testExtendReturnsUniquePrototype()
  local base = {};
  local prototype = extend(base);
  unit.assertNotIs(prototype, extend(base));
end

function testExtendReturnsUniqueConfig()
  local base = {};
  local config = getmetatable(extend(base));
  unit.assertNotIs(config, getmetatable(extend(base)));
end

function testExtendReturnsUniqueIndex()
  local base = {};
  local index = getmetatable(extend(base)).__index;
  unit.assertNotIs(index, getmetatable(extend(base)).__index);
end

function testExtendReturnsUniqueInstance()
  local base = {};
  local instance = getmetatable(extend(base)).instance;
  unit.assertNotIs(instance, getmetatable(extend(base)).instance);
end

function testExtendReturnsUniqueMeta()
  local base = {};
  local meta = getmetatable(extend(base)).meta;
  unit.assertNotIs(meta, getmetatable(extend(base)).meta);
end

function testExtendSetsCallToInitialize()
  local base = {};
  local prototype = extend(base);
  local config = getmetatable(prototype);
  unit.assertEquals(config.__call, extend.initialize);
end

function testExtendIndexNotBase()
  local base = {};
  local prototype = extend(base);
  local config = getmetatable(prototype);
  unit.assertNotIs(config, base);
  unit.assertNotIs(config.__index, base);
end

function testExtendIndexInheritsBase()
  local base = {};
  local prototype = extend(base);
  local config = getmetatable(prototype);
  unit.assertNotIs(getmetatable(config.__index), base);
  unit.assertIs(getmetatable(config.__index).__index, base);
end

function testExtendPrefixedValue()
  local base = {};
  local prototype = extend(base, {__foo="bar"});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.__foo);
  unit.assertEquals(config.meta.__foo, "bar");
end

function testExtendInitializeFunction()
  local base = {}; local value = function() end;
  local prototype = extend(base, {initialize=value});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.initialize);
  unit.assertEquals(config.meta.initialize, value);
end

function testExtendFunction()
  local base = {}; local value = function() end;
  local prototype = extend(base, {foo=value});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertEquals(rawget(config.__index, "foo"), value);
end

function testExtendTable()
  local base = {}; local value = {};
  local prototype = extend(base, {foo=value});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertEquals(rawget(config.__index, "foo"), value);
end

function testExtendString()
  local base = {}; local value = "foo";
  local prototype = extend(base, {foo=value});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertEquals(config.instance.foo, value);
end

function testExtendNumber()
  local base = {}; local value = 42;
  local prototype = extend(base, {foo=value});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertEquals(config.instance.foo, value);
end

function testExtendBoolean()
  local base = {}; local value = true;
  local prototype = extend(base, {foo=value});
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertEquals(config.instance.foo, value);
end

function testPrototypeAddPrefixedValue()
  local base = {}; local value = "bar";
  local prototype = extend(base);
  prototype.__foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.__foo);
  unit.assertIsNil(config.instance.__foo);
  unit.assertIsNil(rawget(config.__index, "__foo"));
  unit.assertEquals(config.meta.__foo, value);
end

function testPrototypeAddFunction()
  local base = {}; local value = function() end;
  local prototype = extend(base);
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.instance.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertEquals(rawget(config.__index, "foo"), value);
end

function testPrototypeAddTable()
  local base = {}; local value = {};
  local prototype = extend(base);
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.instance.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertEquals(rawget(config.__index, "foo"), value);
end

function testPrototypeAddString()
  local base = {}; local value = "foo";
  local prototype = extend(base);
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertIsNil(rawget(config.__index, "foo"));
  unit.assertEquals(config.instance.foo, value);
end

function testPrototypeAddNumber()
  local base = {}; local value = 42;
  local prototype = extend(base);
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertIsNil(rawget(config.__index, "foo"));
  unit.assertEquals(config.instance.foo, value);
end

function testPrototypeAddBoolean()
  local base = {}; local value = true;
  local prototype = extend(base);
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertIsNil(rawget(config.__index, "foo"));
  unit.assertEquals(config.instance.foo, value);
end

function testPrototypeAlterPrefixedValue()
  local base = {}; local value = "bar";
  local prototype = extend(base, {__foo="foo"});
  prototype.__foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.__foo);
  unit.assertIsNil(config.instance.__foo);
  unit.assertIsNil(rawget(config.__index, "__foo"));
  unit.assertEquals(config.meta.__foo, value);
end

function testPrototypeAlterStaticToInstance()
  local base = {}; local value = "bar";
  local prototype = extend(base, {foo=function() end});
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertIsNil(rawget(config.__index, "foo"));
  unit.assertEquals(config.instance.foo, value);
end

function testPrototypeAlterInstanceToStatic()
  local base = {}; local value = function() end;
  local prototype = extend(base, {foo=42});
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.instance.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertEquals(rawget(config.__index, "foo"), value);
end

function testPrototypeAlterInstanceToInstance()
  local base = {}; local value = "bar";
  local prototype = extend(base, {foo=42});
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertIsNil(rawget(config.__index, "foo"));
  unit.assertEquals(config.instance.foo, value);
end

function testPrototypeAlterStaticToStatic()
  local base = {}; local value = function() end;
  local prototype = extend(base, {foo=function() end});
  prototype.foo = value;
  local config = getmetatable(prototype);
  unit.assertIsNil(base.foo);
  unit.assertIsNil(config.instance.foo);
  unit.assertIsNil(config.meta.foo);
  unit.assertEquals(rawget(config.__index, "foo"), value);
end

function testPrototypeExposesStatic()
  local template = {tbl={}, func=function() end, str="foo", num=42, bool=true};
  local prototype = extend({}, template);
  unit.assertIs(prototype.tbl, template.tbl);
  unit.assertEquals(prototype.func, template.func);
  unit.assertIsNil(prototype.str);
  unit.assertIsNil(prototype.num);
  unit.assertIsNil(prototype.bool);
end

function testCanInitialize() unit.assertEquals(type(extend({})()), "table"); end

function testInstanceInheritsPrototype()
  local prototype = extend({});
  local instance = prototype();
  unit.assertIs(getmetatable(instance).__index, getmetatable(prototype).__index);
end

function testInstanceInheritsBaseValues()
  local base = {tbl={}, func=function() end, str="foo", num=42, bool=true};
  local instance = extend(base)();
  unit.assertIs(instance.tbl, base.tbl);
  unit.assertEquals(instance.func, base.func);
  unit.assertEquals(instance.str, base.str);
  unit.assertEquals(instance.num, base.num);
  unit.assertEquals(instance.bool, base.bool);
  base.tbl={}; base.func=function() end; base.str="bar"; base.num=43; base.bool=false;
  unit.assertIs(instance.tbl, base.tbl);
  unit.assertEquals(instance.func, base.func);
  unit.assertEquals(instance.str, base.str);
  unit.assertEquals(instance.num, base.num);
  unit.assertEquals(instance.bool, base.bool);
end

function testInstanceStaticValues()
  local template = {tbl={}, func=function() end};
  local prototype = extend({}, template);
  unit.assertIs(prototype.tbl, template.tbl);
  unit.assertEquals(prototype.func, template.func);
  local instance = prototype();
  unit.assertIs(instance.tbl, template.tbl);
  unit.assertEquals(instance.func, template.func);
  template.tbl={} template.func=function() end;
  unit.assertNotIs(prototype.tbl, template.tbl);
  unit.assertNotIs(instance.tbl, template.tbl);
  prototype.tbl={}; prototype.func=function() end;
  unit.assertIs(instance.tbl, prototype.tbl);
  unit.assertEquals(instance.func, prototype.func);
end

function testInstanceInstanceValues()
  local template = {str="foo", num=42, bool=true};
  local prototype = extend({}, template);
  unit.assertIsNil(prototype.str);
  unit.assertIsNil(prototype.num);
  unit.assertIsNil(prototype.bool);
  unit.assertEquals(template.str, getmetatable(prototype).instance.str);
  unit.assertEquals(template.num, getmetatable(prototype).instance.num);
  unit.assertEquals(template.bool, getmetatable(prototype).instance.bool);
  template.str="bar"; template.num=43; template.bool=false;
  unit.assertNotEquals(template.str, getmetatable(prototype).instance.str);
  unit.assertNotEquals(template.num, getmetatable(prototype).instance.num);
  unit.assertNotEquals(template.bool, getmetatable(prototype).instance.bool);
  local instance = prototype();
  unit.assertEquals(instance.str, getmetatable(prototype).instance.str);
  unit.assertEquals(instance.num, getmetatable(prototype).instance.num);
  unit.assertEquals(instance.bool, getmetatable(prototype).instance.bool);
  getmetatable(prototype).instance.str="baz"; getmetatable(prototype).instance.num=44; getmetatable(prototype).instance.bool=false;
  unit.assertNotEquals(instance.str, getmetatable(prototype).instance.str);
  unit.assertNotEquals(instance.num, getmetatable(prototype).instance.num);
  unit.assertNotEquals(instance.bool, getmetatable(prototype).instance.bool);
  local instance2 = prototype();
  unit.assertEquals(instance2.str, getmetatable(prototype).instance.str);
  unit.assertEquals(instance2.num, getmetatable(prototype).instance.num);
  unit.assertEquals(instance2.bool, getmetatable(prototype).instance.bool);
end

function testInstanceMetaValues()
  local template = {__foo="bar"};
  local prototype = extend({}, template);
  unit.assertIsNil(prototype.__foo);
  unit.assertNotEquals(getmetatable(prototype).__foo, template.__foo);
  unit.assertEquals(getmetatable(prototype).meta.__foo, template.__foo);
  template.__foo="baz";
  unit.assertNotEquals(getmetatable(prototype).meta.__foo, template.__foo);
  local instance = prototype();
  unit.assertIsNil(instance.__foo);
  unit.assertEquals(getmetatable(instance).__foo, getmetatable(prototype).meta.__foo);
  getmetatable(prototype).meta.__foo="qux";
  unit.assertNotEquals(getmetatable(instance).__foo, getmetatable(prototype).meta.__foo);
  local instance2 = prototype();
  unit.assertEquals(getmetatable(instance2).__foo, getmetatable(prototype).meta.__foo);
end

function testInheritanceMultiple()
  local base = {baseStr="base", baseNum=42, baseBool=true, baseTbl={}, baseFunc=function() end};
  local super = {superStr="super", superNum=43, superBool=false, superTbl={}, superFunc=function() end};
  local sub = {subStr="sub", subNum=44, subBool=true, subTbl={}, subFunc=function() end};
  local instance = extend(extend(base, super), sub)();
  unit.assertEquals(instance.baseStr, base.baseStr);
  unit.assertEquals(instance.baseNum, base.baseNum);
  unit.assertEquals(instance.baseBool, base.baseBool);
  unit.assertIs(instance.baseTbl, base.baseTbl);
  unit.assertEquals(instance.baseFunc, base.baseFunc);
  unit.assertEquals(instance.superStr, super.superStr);
  unit.assertEquals(instance.superNum, super.superNum);
  unit.assertEquals(instance.superBool, super.superBool);
  unit.assertIs(instance.superTbl, super.superTbl);
  unit.assertEquals(instance.superFunc, super.superFunc);
  unit.assertEquals(instance.subStr, sub.subStr);
  unit.assertEquals(instance.subNum, sub.subNum);
  unit.assertEquals(instance.subBool, sub.subBool);
  unit.assertIs(instance.subTbl, sub.subTbl);
  unit.assertEquals(instance.subFunc, sub.subFunc);
end

function testInheritanceOverridesFirstToLast()
  local base = {a=1, b=1, c=1};
  local super = {b=2, c=2};
  local sub = {c=3};
  local instance = extend(extend(base, super), sub)();
  unit.assertEquals(instance.a, base.a);
  unit.assertEquals(instance.b, super.b);
  unit.assertEquals(instance.c, sub.c);
end

os.exit(unit.LuaUnit.run());