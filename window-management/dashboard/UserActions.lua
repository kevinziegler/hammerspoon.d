--- Return the user-initiated actions for the Dashboard layout
---
--- This generates a set of mappings for enumerated window manager actions to
--- a set of functions that can be bound to hotkeys or other user-triggered
--- actions.
---
--- Each bound function takes either no arguments (for actions that affect the
--- overall layout) or a single argument for a window object will be acted upon
--- by the layout.
---
--- Along with the action itself, the value contains information on a helpful
--- name for the action, as well as an indicator of whether or not the action
--- is 'repeatble', i.e. one that a user might call multiple times in
--- succession.
---
--- @param layout Layout The layout instance to bind agaisnt
--- @return table A table of actions that can be bound to a modal/hotkeys
local function userActions(layout)
  return {
    moveToLeft = {
      name = "Move focused window left",
      repeatable = true,
      action = function(window) layout:__move(window, { x = -1 }) end
    },

    moveToRight = {
      name = "Move focused window right",
      repeatable = true,
      action = function(window) layout:__move(window, { x = 1 }) end
    },

    moveToUp = {
      name = "Move focused window up",
      repeatable = true,
      action = function(window) layout:__move(window, { y = -1 }) end
    },

    moveToDown = {
      name = "Move focused window down",
      repeatable = true,
      action = function(window) layout:__move(window, { y = 1 }) end
    },
  }
end

return userActions
