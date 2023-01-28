# templates.lua
Simplistic object templating and inheritance

## Usage
>
> ### Extending A Table
> *extending the standard table library*
> ```lua
> -- Create an extension library
> local tableEx = extend(table);
> print(tableEx.getn == table.getn); -- true
>
> -- Override a function on the extension library
> tableEx.getn = function() end;
> print(tableEx.getn == table.getn); -- false
>
> -- Add a new function to the standard library
> table.newFunc = function() end;
> print(tableEx.newFunc == table.newFunc); -- true
>
> -- Add a new function to the extension library
> tableEx.extendedFunc = function() end;
> print(table.extendedFunc == nil); -- true
> ```
>
> ### Creating A Class
> *extending with a class template*
> ```lua
> -- extend(base, template)
> local MyClass = extend({}, {
>   stringProperty = "foo",              -- Instance Property
>   numberProperty = 42,                 -- Instance Property
>   booleanProperty = true,              -- Instance Property
>   functionProperty = function() end,   -- Static Property
>   tableProperty = {},                  -- Static Property
>   __propertyWithPrefix = 123,          -- Metatable Property
>   initialize = function(self,...)      -- Constructor
>     self.constructorArgs = {...};
>   end,
> });
>
> -- The class will expose static properties
> print(type(MyClass.stringProperty)); -- nil
> print(type(MyClass.numberProperty)); -- nil
> print(type(MyClass.booleanProperty)); -- nil
> print(type(MyClass.functionProperty)); -- function
> print(type(MyClass.tableProperty)); -- table
> print(type(MyClass.__propertyWithPrefix)); -- nil
>
> -- The instance will recieve a copy of instance properties
> local instance = MyClass("a", "b", "c");
> print(instance.stringProperty); -- "foo"
> print(instance.numberProperty); -- 42
> print(instance.booleanProperty); -- true
> print(type(instance.functionProperty)); -- function
> print(type(instance.tableProperty)); -- table
> print(getmetatable(instance).__propertyWithPrefix); -- 123
> print(instance.constructorArgs[1]); -- a
> print(instance.constructorArgs[2]); -- b
> print(instance.constructorArgs[3]); -- c
> ```
>
> ### Inheriting A Table Or Class
> *a class that inherits the standard table library*
> ```lua
> local Element = extend(table, {
>   initialize = function(self, top, left, right, bottom)
>     self.top = top;
>     self.left = top;
>     self.right = top;
>     self.bottom = top;
>   end
>   validate = function(self)
>     if (top>bottom or left>right) return false; end
>     for _,child in ipairs(self) do
>       if (!child:validate()) then return false; end
>     end
>     return true;
>   end,
> });
>
> local root = Element(5,5,10,10);
> root:insert(Element(3,7,9,14));
> root:insert(Element(4,4,8,8));
> print(root:validate()); -- true
> root:insert(Element(8,8,4,4));
> print(root:validate()); -- false
> ```
>
> ### Determining Inheritance
> *type matching*
> ```lua
> local SuperClass = extend(table, {});
> local SubClass = extend(SuperClass, {});
> local OtherClass = extend({}, {});
> local instance = SubClass();
>
> print(SubClass:ancestors(instance)); -- true
> print(SuperClass:ancestors(instance)); -- true
> print(extend.ancestors(table, instance)); -- true
> print(OtherClass:ancestors(instance)); -- false
> ```

## API
>
> ### Syntax
> `(table)prototype extend((table)base, (table)template)`
> <table>
>   <tr><th>base</th><td>table</td><td>
>     The table being extended.<br />
>     This can be:
>     <ul>
>       <li>Any table</li>
>       <li>Another prototype/class</li>
>       <li>A standard lua library (e.g. string or table)</li>
>     </ul>
>   </td></tr>
>   <tr><th>template</th><td>table</td><td>
>     The template for the new prototype/class.<br />
>     The key names and value types of the template determine how they are handled:
>     <table>
>       <tr><th>metavalue</th><td>A key prefixed with "__" will be set to an instances metatable</td></tr>
>       <tr><th>constructor</th><td>A key named "initialize" with a function value will be treated as a constructor</td></tr>
>       <tr><th>instance</th><td>String, number and boolean values will be treated as instance values</td></tr>
>       <tr><th>static</th><td>Function and table values will be treated as static values exposed on both the prototype and the instance</td></tr>
>     </table>
>   </td></tr>
>   <tr><th>prototype</th><td>prototype</td><td>
>     Calling the extend library returns a prototype (aka class).<br />
>     The prototype will expose any values from the base and only
>     static methods from the template.<br /> 
>     Calling the prototype will return a new instance.
>   </td></tr>
> </table>
