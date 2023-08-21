local BindingHelper = require('Leader.BindingHelper')
local Binding = require('Leader.Binding')

local Menu = {
  items = {},
  title = nil,
  modal = nil,
  quitKey = { modifiers = nil, key = 'escape' },
  defaultTitle = "🞆",
  __mt = {},
  __noop = function() print("WARNING: invoked menu item without action") end,
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

  binding:bindTo(self.modal, self:__activationFor(binding, action))

  self.items[binding] = action
  return self
end

function Menu:withRepeatingAction(modifiers, key, description, action)
  local binding = Binding(modifiers, key, description, false, true)

  binding:bindTo(self.modal, self:__activationFor(binding, action))

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
  -- TODO Figure out repeating for menus - this is trickier than plain actions,
  --      since we may want to traverse multiple sub-menus before returning to
  --      the 'current level' of menu we're at now.  This probably means passing
  --      some sort of callback function or reference, but I need to think about
  --      how I want that to work (also: a coroutine, maybe?)
  return function (breadcrumbs)
    self:__deactivate()

    action(breadcrumbs)
    -- if Menu.isMenu(action) then
    --   action(breadcrumbs)
    -- else
    --   action()
    -- end

    if binding.repeating then
      self:__activate()
    end
  end
end

return setmetatable(Menu, Menu.__mt)
