local MenuHelperConfig = require('Leader.MenuHelperConfig')

--- Build & display helper menus for modal bindings
-- @type BindingHelper
-- @field hs Global Hammerspoon object
local BindingHelper = {
  hs = nil,
  config = nil,
  symbols = {},
  formatting = nil,
  __displayId = nil,
  __mt = {}
}

BindingHelper.__index = BindingHelper

function BindingHelper.__mt.__call(class, hsGlobal, config)
  return setmetatable(
    {
      hs = hsGlobal,
      config = config or MenuHelperConfig(),
    },
    class
  )
end

function BindingHelper:show(breadcrumbs, items)
  self:hide()
  self.__displayId = self.hs.alert.show(
    self:__helperText(breadcrumbs, items),
    self.config.styles.alert,
    true
  )
end

function BindingHelper:hide()
  if self.__displayId then
    self.hs.alert.closeSpecific(self.__displayId)
    self.__displayId = nil
  end
end

function BindingHelper:__format(string, component, mode)
  return self.hs.styledtext.new(
    string,
    self.config.styles:styleFor((component or "default") .. "." .. mode)
  )
end

function BindingHelper:__repeatHint(binding)
  return self:__format(
    self.config.symbols.repeating .. " ",
    "item.hint",
    binding.repeating and "active" or "inactive"
  )
end

function BindingHelper:__keyHint(binding)
  local hint = "  " .. string.upper(binding.key)

  if self.config.symbols.special[binding.key] then
    hint = self.config.symbols.special[binding.key]
  end

  return self:__format(hint, "description", "active")
end

function BindingHelper:__modifierHint(binding)
  local hint = self:__format("", "modifiers", "active")

  local enabled = binding:enabledModifiers()
  for modifier, symbol in pairs(self.config.symbols.modifiers) do
    local mode = enabled[modifier] and "active" or "inactive"
    hint = hint .. self:__format(symbol, "item.hint", mode)
  end

  return hint .. " "
end

function BindingHelper:__descriptionHint(binding, width)
  local padTo = width
    + self.config.styles:styleFor("item.description").padding
    - utf8.len(binding.description)

  local hint = string.rep(" ", padTo) .. binding.description
  return self:__format(hint, "description", "active")
end

function BindingHelper:__itemHint(binding, descriptionWidth)
  return self:__modifierHint(binding)
    .. self:__keyHint(binding)
    .. self:__descriptionHint(binding, descriptionWidth)
end

function BindingHelper:__header(breadcrumbs, width)
  local header = table.concat(
    breadcrumbs,
    self.config.symbols.header.breadcrumb
  ) .. " "

  local fillWidth = width - utf8.len(header)
  header = header .. string.rep(self.config.symbols.header.fill, fillWidth)

  return self:__format(header, "header", "title")
end

function BindingHelper:__footer(width)
  local quitHint = "(ESC to quit)"
  local footerLine = string.rep(
    self.config.symbols.header.fill, width - utf8.len(quitHint) - 1
  )

  return self:__format("\n" .. footerLine .. " ", "footer", "fill")
    .. self:__format(quitHint, "footer", "hint")
end


function BindingHelper:__helperText(breadcrumbs, items)
  local lineWidth = 0
  local body = self:__format("", nil, "active")
  local descriptionWidth = self
    .config
    .styles:styleFor("item.description").minWidth

  for binding, _ in pairs(items) do
    descriptionWidth = math.max(descriptionWidth, utf8.len(binding.description))
  end

  for binding, _ in pairs(items) do
    local line = self:__itemHint(binding, descriptionWidth)
    lineWidth = math.max(lineWidth, utf8.len(line:getString()))
    body = body .. self:__format("\n", nil, "active") .. line
  end

  return self:__header(breadcrumbs or {}, lineWidth)
    .. body
    .. self:__footer(lineWidth)
end

return setmetatable(BindingHelper, BindingHelper.__mt)
