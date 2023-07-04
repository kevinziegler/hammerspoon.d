local function makeMock()
  local obj = {
    __calls = {},
    __mocks = {},
  }

  setmetatable(obj, obj)

  function obj.mock(key, mockFn)
    obj.__mocks[key] = mockFn
  end

  function obj.mockReturn(method, value)
    obj.mock(method, function() return value end)
  end


  function obj.__index(_, key)
    if not obj.__mocks[key] then
        error("Could not find mock for " .. key .. "!")
    end

    return function(...)
      obj.__calls[key] = obj.__calls[key] or {}
      table.insert(obj.__calls[key], { ... })
      return obj.__mocks[key](...)
    end
  end


  function obj.mockMethod(methodName, mockFn)
    obj[methodName] = function(self, ...)
      self.__calls[methodName] = self.__calls[methodName] or {}
      table.insert(self.__calls[methodName], { ... })
      return mockFn(...)
    end
  end

  return obj
end

m = makeMock()
m.mock("foo", function() return "bar" end)
m.mock("bar", function() return "baz" end)
m.mockReturn("qux", 42)

print("m.foo " .. m.foo())
print("m.bar " .. m.bar())
print("m.qux " .. m.qux())

m.someVar = 56

print("m.somvVar " ..m.someVar)


m.mockMethod("thing", function() return 314 end)

print("Thing is " .. m:thing())
