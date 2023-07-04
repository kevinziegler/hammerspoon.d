require('partition')

function MockGrid()
  local mock = {
    __calls = {}
  }

  function mock.set(...)
    mock.__calls.set = mock.__calls.set or {}
    mock.__calls.set[#mock.__calls + 1] = {...}
  end

  return mock
end


MockWindow = { __calls = {}, __id = nil, }

MockWindow.__index = MockWindow

function MockWindow:new(id)
  local mock = {}

  mock.__calls = {}
  mock.__id = id
  setmetatable(mock, MockWindow)

  return mock
end

function MockWindow:__addCall(methodName, args)
  self.__calls[methodName] = self.__calls[methodName] or {}
  table.insert(self.__calls[methodName], args)
end

function MockWindow:id()
  self:__addCall("id", {})
  return self.__id
end

PartitionTests = {
  [":add()"] = {
    should = {
        addWindowToPartition = function()
            local windowId = "TEST_WINDOW"
            local dimensions = { x = 0, y = 0, w = 0, h = 0 }
            local grid = MockGrid()
            local window = MockWindow:new(windowId)

            local partition = Partition:new(
                grid,
                dimensions,
                Partition.SPLITS.HORIZONTAL,
                {}
            )

            partition:add(window)
            for _, partitionWindow in pairs(partition:getWindows()) do
                if partitionWindow == window then
                    return true
                end
            end

            error("Could not find window in table!")
        end,

        updateWindowDimensions = function()
            local windowId = "TEST_WINDOW"
            local dimensions = { x = 0, y = 0, w = 0, h = 0 }
            local grid = MockGrid()
            local window = MockWindow:new(windowId)

            local partition = Partition:new(
                grid,
                dimensions,
                Partition.SPLITS.HORIZONTAL,
                {}
            )

            partition:add(window)

            if #grid.__calls.set ~= 1 then
                error("Expected 1 call to grid:set(), but got " .. #grid.__calls.set)
            end
        end,
    }

  },

  ["split()"] = {
    when = {
      ["partition has no children"] = {},
      ["partition has children"] = {},
      ["split direction is vertical"] = {},
      ["split direction is horizontal"] = {},
    }
  },

  ["remove()"] = {
    when = {
      ["partition has no children"] = {}
    }
  }
}


local function runTests(suite, prefix)
  prefix = (prefix or "") .. " "

  for key, value in pairs(suite) do
    if type(value) == "function" then
      local status, err = pcall(value)
      print(prefix .. key .. ": " .. (status and "PASS" or "FAIL: " .. err))
    else
      runTests(value, prefix .. key)
    end
  end
end

runTests(PartitionTests, "Partition")
