--- Return the user-initiated actions for a 3-column Ultrawide layout
---
--- @param layout Layout The layout instance to bind against
--- @return table A talbe of actions that can be bound to a modal/hotkeys
local function userActions(layout)
  local function moveTo(column)
    return function(window)
      layout:moveTo(window, column)
    end
  end

  return {
    growMain = {
      name = "Grow Main Column",
      repeatable = true,
      action = function() layout:growMain() end,
    },

    shrinkMain = {
      name = "Shrink Main Column",
      repeatable = true,
      action = function() layout:shrinkMain() end
    },

    reset = {
      name = "Reset Column Dimensions",
      repeatable = true,
      action = function() layout:reset() end
    },

    moveToLeft = {
      name = "Move window to left column",
      action = moveTo("left")
    },

    moveToRight = {
      name = "Move window to right column",
      action = moveTo("right")
    },

    moveToMain = {
      name = "Move window to main column",
      action = moveTo("main")
    },
  }
end

return userActions
