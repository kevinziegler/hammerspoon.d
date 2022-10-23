require 'io'

-- TODO address path issue to find emacsclient
emacsclient = '/opt/homebrew/bin/emacsclient'
emacsclientFlags = '-nqe'
orgCaptureSerializer = '(kdz/serialize-org-captures)'
getCaptureKeysCommand = string.format(
  '%s %s "%s"',
  emacsclient,
  emacsclientFlags,
  orgCaptureSerializer
)

orgCaptureScript = "/Users/kevinziegler/.emacs.d/bin/org-capture"

function initCaptureTreeNode(description)
  return { ["children"] = {}, ["description"] = description }
end

function insertCaptureTreeNode(parent, keys, fullKeys, description)
  prefix = string.sub(keys, 1, 1)
  suffix = string.sub(keys, 2)

  -- Initialize the node for the current prefix if it doesn't already exist
  if not parent.children[prefix] then
    parent.children[prefix] = initCaptureTreeNode()
  end

  node = parent.children[prefix]

  if suffix == '' then
    -- End of keys string; insert description
    node.description = description
    node.fullKeys = fullKeys
  else
    insertCaptureTreeNode(node, suffix, fullKeys, description)
  end
end

function launchCapture(keys)
  return function()
    -- TODO This doesn't launch org-capture, for whatever reason >_<
    hs.task.new(orgCaptureScript, nil, {"-k", keys}):start()
  end
end

function getOrgCaptureKeys()
  -- TODO Add error handling on !success
  out, success = hs.execute(getCaptureKeysCommand)

  captureKeys = hs.json.decode(hs.json.decode(out))
  captureRoot = initCaptureTreeNode("Org Capture")

  for keys, description in pairs(captureKeys) do
    insertCaptureTreeNode(captureRoot, keys, keys, description)
  end

  return captureRoot
end

function captureKeyBindings(node, binder)
  if not next(node.children) then
    return launchCapture(node.fullKeys)
  end

  local bindings = {}
  for key, child in pairs(node.children) do
    childBindings = captureKeyBindings(child, binder)
    bindings[binder(key, child.description)] = childBindings
  end

  return bindings
end
