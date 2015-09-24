
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = true

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
-- CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

LUA_UPDATE = false

LUA_UI_EDITOR = false

DATA_CONFIG_PACKAGE = "app.config."

UI_MANAGER_PATH = "app.view.UIManager"

IS_DEBUG = true

if IS_DEBUG then
	DEBUG_FPS = true
	LOG_LEVEL = {DEBUG = true, INFO = true, WARN = true, ERROR = true, FATAL = true}
else
	DEBUG_FPS = false
	LOG_LEVEL = {DEBUG = false, INFO = false, WARN = false, ERROR = true, FATAL = true}
end