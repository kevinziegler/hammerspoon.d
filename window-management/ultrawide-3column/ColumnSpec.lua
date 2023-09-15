local Partition = {
  children = {},
  __grid = nil,
  __mt = {},
}

function Partition.__mt.__call(gridFn)
  self.__grid = gridFn
end

function Partition:addChild()
end

function Partition:splitVertical()
end

function Partition:splitHorizontal()
end
