local utilities = {}

function utilities.launch(applicationName)
  return function() hs.application.launchOrFocus(applicationName) end
end

function utilities.bindKeymap(keymap, binder)
  local bindFn = require('keymaps.' .. keymap)
  return bindFn(binder)
end

return utilities
