-- Describe a modal binding in the Leader menu

local modifierKeys = {
    COMMAND = "COMMAND",
    OPTION  = "OPTION",
    SHIFT   = "SHIFT",
    CONTROL = "CONTROL"
}

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

  MODIFIER = {
    KEYS = modifierKeys,
  },

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

function Binding:bindTo(modal, action)
  modal:bind(self.modifiers, self.key, action)
end

function Binding:enabledModifiers()
  local enabled = {}
  for _, modifier in pairs(self.modifiers) do
    enabled[modifier] = true
  end

  return enabled
end

return setmetatable(Binding, Binding.__mt)
