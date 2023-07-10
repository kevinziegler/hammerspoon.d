local keys = require("Leader.keys")
local util = require("Leader.util")

local MenuItem = {
  key = nil,
  modifiers = nil,
  description = nil,
  action = nil,
  itemType = nil,

  TYPES = util.makeTypes("MENU", "ACTION", "REPEATING")
}

MenuItem.__index = MenuItem

--- Create a new MenuItem instance
--- @param key string The keyboard character to bind this menu item
--- @param modifiers table
function MenuItem:new(modifiers, key, description, action, itemType)
  local obj = {}
  setmetatable(obj, MenuItem)

  obj.itemType = itemType
  obj.key = key
  obj.description = description
  obj.action = action

  obj.modifiers = {}
  for _, modifier in pairs(modifiers) do
    obj.modifiers[modifier] = true
  end

  -- Show capital letters with the shift key implicitly
  if "A" <= key and "Z" >= key then
    obj.modifiers[keys.modifiers.SHIFT] = true
  end

  return obj
end

---@return string
function MenuItem:itemHelper(helperConfig)
  local hint = string.upper(self.key)
  local displayModifiers = { table.unpack(self.modifiers or {}) }
  local modifierHint = ""

  for _, modifier in ipairs(helperConfig.orderedModifiers) do
    modifierHint = modifierHint ..
        (self.modifiers[modifier] and helperConfig.modifierHints[modifier].hint or " ")
  end

  return modifierHint
    .. " "
    .. hint
    .. helperConfig.keyIndicator
    .. self.description
end

--- Return a normalized type for a given MenuItem
---
--- Prefer the specified itemType if it is a valid type from menuItemTypes,
--- otherwise the type is inferred based on the value of the item's action
--- @return string
function MenuItem:resolvedType()
  if self.TYPES[self.itemType] then
    return self.itemType
  elseif type(self.action) == "Menu" then
    return self.TYPES.MENU
  elseif type(self.action) == "function" then
    return self.TYPES.ACTION
  else
    error("Unkown action type for " .. self)
  end
end

function MenuItem:bindingModifiers()
  local bindingModifiers = {}

  for modifier, set in pairs(self.modifiers) do
    if set then
      bindingModifiers[#bindingModifiers+1] = string.lower(modifier)
    end
  end

  return bindingModifiers
end


function MenuItem:makeBindingFunction(menu)
  -- TODO I _think_ if I use a bool for the 'repeating' property I can get some
  -- more mileage out of this:
  -- - A repeating item with a 'menu' type allows me to spawn a stack of menus
  --   that I can move through, eventually returning up to the current menu
  -- - "Type" detection can be simplified (functions that generate menus can
  --   also be identified by a boolean flag)
  return function()
    if self:resolvedType() ~= MenuItem.TYPES.REPEATING then
      menu:deactivate()
    end

    self:invoke()
  end
end

function MenuItem:invoke()
  if self:resolvedType() == MenuItem.TYPES.MENU then
    self.action:activate()
  else
    return self.action()
  end
end

--- Bind this MenuItem to the supplied modal
---
--- @param modal hs.hotkey.modal
function MenuItem:bindToMenu(menu)
  menu.modal:bind(
    self:bindingModifiers(),
    string.lower(self.key),
    self:makeBindingFunction(menu)
  )
end

return MenuItem
