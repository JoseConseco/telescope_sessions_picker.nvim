# Telescope Sessions loader
Load nvim session files from target directory

![Session Thumb](./img/./session_picker.jpg)

## Install

```
use 'JoseConseco/telescope_sessions_picker.nvim'
```

## Configuration
This extension can be configured using `extensions` field inside Telescope
setup function.

```lua
require'telescope'.setup {
  -- your existing tele config
  extensions = {
    sessions_picker = {
      sessions_dir = vim.fn.stdpath('data') ..'/session/',  -- same as '/home/user/.local/share/nvim/session'
    }
    -- other tele extensions configs
  },
}
require('telescope').load_extension('sessions_picker')
```

## Hotkeys
`<CR>` - open Session file (same as :so your_session_file)

`<DEL>` - remove selected session file (not the project file, just session file!)

`<C-n>` - create new session from cwd.

## Available commands
```viml
:Telescope sessions_picker

"Using lua function
lua require('telescope').extensions.sessions_picker.sessions_picker()
```



