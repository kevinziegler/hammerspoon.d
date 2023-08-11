local defaultSymbols = {
    modifiers = {
      control = '⌃',
      command = '⌘',
      option = '⌥',
      shift = '⇧',
    },

    special = {
      tab = "TAB",
      escape = "ESC",
      space = "SPC"
    },

    repeating = '⥁',
}

local defaultFormatting = {
  description = {
    padding = 4,
    minWidth = 40,
  },

  modifiers = {
    keySeparator = "+",
  },

  header = {
    fillChar = "—",
    hsStyles = {
      title = {
        color = { hex = "CBCCC6", alpha = 1.0 },
        font = { name = "Berkeley Mono", size = 18 },
      },

      fill = {
        color = { hex = "CBCCC6", alpha = 0.5 },
        font = { name = "Berkeley Mono", size = 18 },
      },
    }
  },

  footer = {
    hsStyles = {
      hint = {
        color = { hex = "CBCCC6", alpha = 0.5 },
        font = { name = "Berkeley Mono", size = 18 },
      },

      fill = {
        color = { hex = "CBCCC6", alpha = 0.5 },
        font = { name = "Berkeley Mono", size = 18 },
      },
    }
  },

  hsStyles = {
    active = {
      color = { hex = "CBCCC6", alpha = 1.0 },
      font = { name = "Berkeley Mono", size = 18 },
    },

    inactive = {
      color = { hex = "CBCCC6", alpha = 0.1 },
      font = { name = "Berkeley Mono", size = 18 },
    },

    default = {
      color = { hex = "CBCCC6", alpha = 1.0 },
      font = { name = "Berkeley Mono", size = 18 },
    },

    alert = {
      fillColor = { hex = "#1F2430", alpha = 0.95 },
      strokeWidth = 5,
      strokeColor = { hex = "#CBCCC6", alpha = 1.0 },
      radius = 7,
    }
  }
}

--- Build & display helper menus for modal bindings
-- @type BindingHelper
-- @field items #map<Binding, Action> Bindings & actions for the menu
-- @field display hs.alert Handler for displaying alerts
local BindingHelper = {
  items = {},
  hs = nil,
  symbols = {},
  formatting = nil,
  __displayId = nil,
  __mt = {}
}

BindingHelper.defaultFormatting = defaultFormatting
BindingHelper.defaultSymbols = defaultSymbols

BindingHelper.__index = BindingHelper

function BindingHelper.__mt.__call(class, items, hsGlobal, formatting, symbols)
  return setmetatable(
    {
      items = items,
      hs = hsGlobal,
      formatting = formatting or class.defaultFormatting,
      symbols = symbols or class.defaultSymbols,
    },
    class
  )
end

-- TODO Implement styles as a deep merge with defaults to allow partial
--      overrides
function BindingHelper:__format(string, component, mode)
  local componentRoot = self.formatting[component] or {}
  local componentStyle = componentRoot.hsStyles or self.formatting.hsStyles
  local applied = componentStyle[mode]

  return self.hs.styledtext.new(string, applied)
end

function BindingHelper:__repeatHint(binding)
  local mode = binding.repeating and "active" or "inactive"
  return self:__format(self.symbols.repeating .. " ", "repeating", mode)
end

function BindingHelper:__keyHint(binding)
  local hint = "  " .. string.upper(binding.key)

  if self.symbols.special[binding.key] then
    hint = self.symbols.special[binding.key]
  end

  return self:__format(hint, "description", "active")
end

function BindingHelper:__modifierHint(binding)
  local hint = self:__format("", "modifiers", "active")

  local enabled = binding:enabledModifiers()
  for modifier, symbol in pairs(self.symbols.modifiers) do
    mode = enabled[modifier] and "active" or "inactive"
    hint = hint .. self:__format(symbol, "modifier", mode)
  end

  return hint .. " "
end

function BindingHelper:__descriptionHint(binding, width)
  local padTo = width
    + self.formatting.description.padding
    - utf8.len(binding.description)

  local hint = string.rep(" ", padTo) .. binding.description
  return self:__format(hint, "description", "active")
end

function BindingHelper:__itemHint(binding, descriptionWidth)
  return -- self:__repeatHint(binding)
    self:__modifierHint(binding)
    .. self:__keyHint(binding)
    .. self:__descriptionHint(binding, descriptionWidth)
end

function BindingHelper:__header(title, width)
  local fill = string.rep(
    self.formatting.header.fillChar,
    width - utf8.len(title) - 1
  )


  return self:__format(title .. " ", "header", "title")
    .. self:__format(fill, "header", "fill")
end

function BindingHelper:__footer(width)
  local quitHint = "(ESC to quit)"
  local footerLine = string.rep(
    self.formatting.header.fillChar, width - utf8.len(quitHint) - 1
  )

  return self:__format("\n" .. footerLine .. " ", "footer", "fill")
    .. self:__format(quitHint, "footer", "hint")
end

function BindingHelper:__helperText()
  local helperLines = {}
  local descriptionWidth = self.formatting.description.minWidth
  local lineWidth = 0
  local body = self:__format("", nil, "active")

  for binding, action in pairs(self.items) do
    descriptionWidth = math.max(descriptionWidth, utf8.len(binding.description))
  end

  for binding, action in pairs(self.items) do
    local line = self:__itemHint(binding, descriptionWidth)
    lineWidth = math.max(lineWidth, utf8.len(line:getString()))
    body = body .. self:__format("\n", nil, "active") .. line
  end

  return self:__header("Actions", lineWidth)
    .. body
    .. self:__footer(lineWidth)
end

function BindingHelper:show()
  self:hide()
  self.__displayId = self.hs.alert.show(
    self:__helperText(),
    self.formatting.hsStyles.alert,
    true
  )
end

function BindingHelper:hide()
  if self.__displayId then
    self.hs.alert.closeSpecific(self.__displayId)
    self.__displayId = nil
  end
end

return setmetatable(BindingHelper, BindingHelper.__mt)
