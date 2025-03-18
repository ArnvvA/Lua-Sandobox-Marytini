
from lupa import LuaRuntime

def main():
    # Initialize Lua runtime
    lua = LuaRuntime(unpack_returned_tuples=True)

    # Basic Lua code execution
    print("\n1. Basic Lua code execution:")
    result = lua.eval('"Hello from Lua!"')
    print(f"Lua says: {result}")

    # Data type conversion
    print("\n2. Data type conversion:")
    lua_code = '''
        function test_types(py_num, py_str, py_list)
            -- Print received Python values
            print("Received from Python:")
            print("Number:", py_num)
            print("String:", py_str)
            local list_str = ""
            for i=1,#py_list do
                list_str = list_str .. tostring(py_list[i]) .. " "
            end
            print("Table from list:", list_str)
            
            -- Return multiple types to Python
            return 42, "Lua String", {1, 2, 3, key = "value"}
        end
    '''
    
    lua.execute(lua_code)
    # Convert Python list to Lua table
    lua_list = lua.table_from([1, 2, 3])
    lua_function = lua.globals().test_types
    num, string, table = lua_function(123, "Python String", lua_list)
    
    print("\nReceived from Lua:")
    print(f"Number: {num}")
    print(f"String: {string}")
    print(f"Table: {dict(table)}")

    # Python function calling from Lua
    print("\n3. Calling Python from Lua:")
    def python_function(x):
        return f"Python processed: {x}"

    lua.globals().py_func = python_function
    result = lua.eval('py_func("test data")')
    print(f"Result: {result}")

    # Error handling
    print("\n4. Error handling:")
    try:
        lua.eval('error("This is a Lua error")')
    except Exception as e:
        print(f"Caught Lua error: {e}")

if __name__ == "__main__":
    main()