local helper = {}

-- Describe supported types of bindings in a menu.  These types are used
-- to determine how to organize items in the helper modal:
--  - MENU :: Selecting this item will display a new sub-menu
--  - TERMINATING_ACTION :: Execute some function & terminate the helper
--  - LOOPED_ACTION :: Execute some function & return to the current menu
helper.menuItemTypes = {
  MENU               = "MENU",
  TERMINATING_ACTION = "TERMINATING_ACTION",
  LOOPED_ACTION      = "LOOPED_ACTION"
}

helper.keyIndicator = ' → '

helper.modifierHints = {
   CONTROL = { weight = 1 , hint = '⌃' },
   SHIFT   = { weight = 2 , hint = '⇧' },
   COMMAND = { weight = 3 , hint = '⌘' },
   OPTION  = { weight = 4 , hint = '⌥' },
}

function helper.orderedModifiers()
  local sorted = {}
  for modifier, hint in pairs(helper.modifierHints) do
    sorted[hint.weight] = modifier
  end

  return sorted
end

function helper.menuItemCompare(itemA, itemB)
  if string.upper(itemA.key) ~= string.upper(itemB) then
    return string.upper(itemA.key) > string.upper(itemB.key)
  end

  local modifierWeightA = 0
  local modifierWeightB = 0

  for modifier, hint in pairs(helper.modifierHints) do
    if itemA.modifiers[modifier] then
      modifierWeightA = modifierWeightA + hint.weight
    end
    if itemB.modifiers[modifier] then
      modifierWeightB = modifierWeightB + hint.weight
    end
  end

  return modifierWeightA > modifierWeightB
end

return helper
