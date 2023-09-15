local util = require('window-management.util')

local layouts = {
  Dashboard = require("window-management.dashboard.Layout"),
  UltrawideThreeColumn = require("window-management.ultrawide-3column.Layout"),
  Sidecar = require("window-management.sidecar.Layout"),
  Maximized = require("window-management.maximized.Layout"),
}

local actions = {
  UltrawideThreeColumn = require("window-management.ultrawide-3column.UserActions"),
}

local configurations = {
  maximized = {
    class = layouts.Maximized,
    initialize = layouts.Maximized,
  },

  dashboard = {
    class = layouts.Dashboard,
    initialize = function() return layouts.Dashboard(hs.grid) end,
  },

  sidecar = {
    class = layouts.Sidecar,
    initialize = function() return layouts.Sidecar(1, 24, 12) end,
    resolutions = { "2560x1664" }
  },

  ultrawide = {
    class = layouts.UltrawideThreeColumn,
    initialize = function() return layouts.UltrawideThreeColumn(hs.grid, 24, 12, hs.window.focusedWindow) end,
    resolutions = { "5120x1440" },
    bindActions = actions.UltrawideThreeColumn
  },
}

local function isCompatible(screen, configuration)
  if not configuration.resolutions then
    return true
  end

  local screenSize = screen:fullFrame()
  local actual = math.floor(screenSize.w) .. "x" .. math.floor(screenSize.h)

  for _, resolution in pairs(configuration.resolutions) do
    if resolution == actual then
      return true
    end
  end

  return false
end

local function buildChoices(screen)
  local choices = {}
  table.sort(configurations)

  for key, configuration in pairs(configurations) do
    if isCompatible(screen, configuration) then
      util.debug(
        "Found compatible CONFIGURATION for layout selection",
        configuration.class.NAME
      )
      table.insert(choices, { text = configuration.class.NAME, key = key })
    end
  end

  return choices
end

local function chooseLayout(manager, space)
  local valid = buildChoices(manager.screen)

  local function onSelected(selected)
    if not (selected and selected.key and configurations[selected.key]) then
        util.debug("Invalid layout configuration:", selected)
        return
    end

    local toApply = configurations[selected.key]

    util.debug("Activating layout: ", toApply.class.NAME)
    manager:setLayoutForSpace(configurations[selected.key].initialize(), space)
  end

  hs.chooser.new(onSelected)
    :choices(valid)
    :placeholderText("Select a layout for " .. manager.screen:name())
    :rows(#valid)
    :show()
end

return chooseLayout
