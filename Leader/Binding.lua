-- Describe a modal binding in the Leader menu

--- A Leader key binding
-- @type Binding
-- @field modifiers table Modifier keys for the binding
-- @field key string The key used to activate the binding
-- @field description string The description of the binding
-- @field repeating boolean Flag to indicate that the action should be repeatable
-- @field asMenu boolean Flag to indicate that the action should be considered a Menu
local Binding = {
  modifiers = {},
  key = nil,
  description = nil,
  repeating = false,
  asMenu = false,
  __mt = {}
}

Binding.__index = Binding

local function normalizeKeys(modifiers, key)
  local keyNormalized = string.lower(key)

  -- If the supplied key was an upper-case letter, set the shift-key modifier
  -- for this binding
  if keyNormalized ~= key then
    local shiftModifierSet = false

    for _, modifier in pairs(modifiers) do
      if modifier == "shift" then
        shiftModifierSet = true
        break
      end
    end

    if not shiftModifierSet then
      modifiers[#modifiers + 1] = "shift"
    end
  end

  return modifiers, keyNormalized
end

--- Create a new binding instance
---
--- @param modifiers table Binding modifiers as a list of strings
--- @param key string The key used for this binding
--- @param description string A description to show in the menu helper
--- @param repeating A boolean flag to indicate this menu item
function Binding.__mt.__call(
    class,
    modifiers,
    key,
    description,
    repeating,
    asMenu
)
  local modifiersNormalized, keyNormalized = normalizeKeys(modifiers, key)

  return setmetatable(
    {
      modifiers = modifiersNormalized,
      key = keyNormalized,
      description = description,
      repeating = repeating,
      asMenu = asMenu
    },
    class
  )
end

function Binding.repeats(modifiers, key, description, asMenu)
  return Binding(modifiers, key, description, true, asMenu)
end

--- Configure this binding as a repeating binding
---
--- Repeated bindings will return to the menu where they were invoked from after
--- completing their associated action.
---
--- @return Binding This binding instance
function Binding:repeating()
  self.repeating = true
  return self
end

--- Configure this binding as a menu binding
---
--- This overrides any detection based on the type of the action associated to
--- the binding, allowing (for example) supplying a function that generates a
--- menu as an action.
---
--- @return Binding This binding instance
function Binding:asMenu()
  self.asMenu = true
  return self
end

--- Bind this modifier to a modal with the supplied action
---
--- @param modal hs.modal The modal instance to bind to
--- @param action function The callback to invoke for this binding
function Binding:bindTo(modal, action)
  modal:bind(self.modifiers, self.key, action)
end

--- Return the set of active modifiers for this binding
---
--- The modifier strings themselves are keys in the set, so checking if a
--- modifier would be required can be performed by indexing that modifier in
--- the set.
---
--- @return table A set of modifiers
function Binding:enabledModifiers()
  local enabled = {}
  for _, modifier in pairs(self.modifiers) do
    enabled[modifier] = true
  end

  return enabled
end

return setmetatable(Binding, Binding.__mt)
