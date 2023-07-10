local helper = require("Leader.helper")
local MenuItem = require("Leader.MenuItem")

local Menu = {
  title = "",
  items = {},
  modal = nil,
}

Menu.__index = Menu

function Menu:new(title, items)
  local obj = {}
  setmetatable(obj, Menu)

  obj.items = items
  obj.modal = hs.hotkey.modal.new()

  for _, item in pairs(self.items) do
    item:bindToMenu(obj)
  end

  return obj
end

function Menu:menuItemsForType(itemType)
  local filtered = {}
  for _, item in pairs(self.items) do
    if item:resolvedType() == itemType then
      table.insert(filtered, item)
    end
  end

  table.sort(filtered, helper.menuItemCompare)

  return filtered
end

function Menu:terminationActions()
  return self:menuItemsForType(MenuItem.TYPES.ACTION)
end

function Menu:subMenus()
  return self:menuItemsForType(MenuItem.TYPES.MENU)
end

function Menu:loopedActions()
  return self:menuItemsForType(MenuItem.TYPES.REPEATING)
end

function Menu:showHelper()
  self.helperId = hs.alert.show("FIXME")
end

function Menu:killHelper()
  if self.helperId then
    hs.alert.closeSpecific(self.helperId)
  end
end

--- Activate the modal backing this menu
---
--- Additionally, display the helper for this menu.  If a parent Menu is
--- provided, then the helper for that
---
--- @param parent Menu The parent menu to the current menu being activated
function Menu:activate()
  self.modal:enter()
  self:showHelper()
end

function Menu:deactivate(action)
  self:killHelper()
  self.modal:exit()
end

--- @return function A function to activate this menu
function Menu:activation()
  return function()
    self:activate()
  end
end

return Menu


-- Example Usage
-- myMenu = Menu( ... items ... )
--
-- hs.hotkey.bind({'command'}, 'space', myMenu:activation())
