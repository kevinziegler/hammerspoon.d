local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function deepMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                deepMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

local function splitStylePath(path)
   local components={}
   for str in string.gmatch(path, "([^.]+)") do
      table.insert(components, str)
   end
   return pairs(components)
end

local function withOverrides(base, overrides)
  return deepMerge(deepCopy(base), overrides)
end


local ConfigMetaclass = {}

function ConfigMetaclass.__call(class, overrides)
  local instance = withOverrides(class, overrides or {})
  instance.__index = class
  return setmetatable(withOverrides(class, overrides or {}), class)
end

local MenuSymbols = {
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

    header = {
      breadcrumb =  " ❱ ",
      fill = "—"
    },

    repeating = '⥁',
}

setmetatable(MenuSymbols, ConfigMetaclass)

MenuStyles = {
  header = {
    fill = { color = { alpha = 0.5 } },
  },

  footer = {
    hint = { color = { alpha = 0.5 } },
    fill = { color = { alpha = 0.5 } },
  },

  item = {
    description = { padding = 4, minWidth = 40 },
    hint = {
      inactive = { color = { alpha = 0.1 } }
    }
  },

  default = {
    base = {
      color = { hex = "CBCCC6", alpha = 1.0 },
      font = { name = "Berkeley Mono", size = 18 },
    },
  },

  alert = {
    fillColor = { hex = "#1F2430", alpha = 0.95 },
    strokeWidth = 5,
    strokeColor = { hex = "#CBCCC6", alpha = 1.0 },
    radius = 7,
  },
}

function MenuStyles:base()
  return deepCopy(self.default.base)
end

function MenuStyles:styleFor(stylePath)
  local selected = self

  for _, component in splitStylePath(stylePath) do
    selected = selected[component] or {}
  end

  return deepMerge(self:base(), selected)
end

setmetatable(MenuStyles, ConfigMetaclass)

MenuConfig = {
  styles = nil,
  symbols = nil,
  __mt = {},
}

MenuConfig.__index = MenuConfig

function MenuConfig.__mt.__call(class, styles, symbols)
  return setmetatable(
    {
      styles = MenuStyles(styles),
      symbols = MenuSymbols(symbols),
    },
    class
  )
end

setmetatable(MenuConfig, MenuConfig.__mt)

return MenuConfig
