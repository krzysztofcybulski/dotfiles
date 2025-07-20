-- [[ Global Settings ]] ------------------------------------------------------
Hyper = { "cmd", "ctrl", "option", "shift" }

hs.automaticallyCheckForUpdates(true)
hs.menuIcon(true)
hs.dockIcon(false)

local function reload_config(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

-- Reload the config every time it changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.dotfiles/config/hammerspoon/", reload_config):start()

-- [[ Modules ]] --------------------------------------------------------------
require("apple-music-spotify-redirect")
require("keymaps")