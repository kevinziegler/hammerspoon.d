local util = {}

function util.makeTypes(...)
  local typeItems = {}

  for index, value in ipairs({...}) do
    typeItems[value] = value
  end

  return typeItems
end

return util
