# Telescope Sessions loader
Load nvim session files from target directory



## Install
Plug 'nvim-telescope/telescope-sessions-picker.nvim'

```
## Setup

``` lua
require('telescope').load_extension('sessions_picker')

```

## Configuration
This extension can be configured using `extensions` field inside Telescope
setup function.

```lua
require'telescope'.setup {
  extensions = {
    sessions_picer = {
      sessions_dir = '',
    }
  },
}
```

## Available commands
```viml
:Telescope sessions_picker

"Using lua function
lua require('telescope').extensions.media_files.media_files()
```



