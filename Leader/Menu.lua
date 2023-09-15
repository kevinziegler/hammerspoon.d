local BindingHelper = require('Leader.BindingHelper')
local Binding = require('Leader.Binding')

local Menu = {
  items = {},
  title = nil,
  modal = nil,
  quitKey = { modifiers = nil, key = 'escape' },
  defaultTitle = "🞆",
  __mt = {},
}

Menu.__index = Menu

-- This allows us to treat a Menu object as a function (taking no arguments),
-- which in turn allows us to treat actions in a menu simply as 'callables',
-- where we don't care if the action is simply a callback function or a
-- sub-menu.
function Menu.__call(this, breadcrumbs)
  return this:__activate(breadcrumbs)
end

-- Constructor for new menu instances
function Menu.__mt.__call(this, items, hsGlobal, title)
  local menu = setmetatable(
    {
      title = title,
      items = items,
      modal = hsGlobal.hotkey.modal.new(),
      helper = BindingHelper(hsGlobal)
    },
    this
  )

  menu:__bind()

  return menu
end

function Menu.named(title, hsGlobal)
  return Menu({}, hsGlobal, title)
end

function Menu:withAction(modifiers, key, description, action)
  local binding = Binding(modifiers, key, description)
  return self:withBinding(binding, action)
end

function Menu:withRepeatingAction(modifiers, key, description, action)
  local binding = Binding(modifiers, key, description, false, true)

  return self:withBinding(binding, action)
end

function Menu:withSubmenu(modifiers, key, description, submenu)
  local binding = Binding(modifiers, key, description):asMenu()
  return self:withBinding(binding, menu)
end

function Menu:withBinding(binding, action)
  self.items[binding] = action
  return self
end

function Menu:__helper()
  return BindingHelper()
end

function Menu.isMenu(object)
  return getmetatable(object) == Menu
end

function Menu:__bind()
  for binding, action in pairs(self.items) do
    binding:bindTo(self.modal, self:__activationFor(binding, action))
  end

  self.modal:bind(self.quitKey.modifiers, self.quitKey.key, self:deactivate())
end

function Menu:__activate(breadcrumbs)
  breadcrumbs = breadcrumbs or {}
  breadcrumbs[#breadcrumbs+1] = self.title or self.defaultTitle
  self.modal:enter()
  self.helper:show(breadcrumbs, self.items)
end

function Menu:activate()
  return function()
    self:__activate()
  end
end

function Menu:__deactivate()
  self.helper:hide()
  self.modal:exit()
end

function Menu:deactivate()
  return function()
    self:__deactivate()
  end
end

function Menu:__activationFor(binding, action)
  return function (breadcrumbs)
    self:__deactivate()

    action(breadcrumbs)

    if binding.repeating then
      self:__activate()
    end
  end
end

return setmetatable(Menu, Menu.__mt)
