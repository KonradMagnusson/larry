# Larry
## What?
A quick and dirty hack to invoke CMake-like build systems from Neovim.   
**Disclaimer:** I don't quite know what I'm doing; this has been a learning experience.

## Why?
Because switching to a different terminal to do things is a hassle.

## How?
### Installation
Using [Packer](https://github.com/wbthomason/packer.nvim):   
```lua
use { "konradmagnusson/larry", tag="v1.0.0" }
```

### Configuration
### Setup
```lua
require("larry").setup({
    available_presets = function( cwd )
            return { "release", "debug" }
        end,
    default_preset = "release",
    build_command = "build %s",
    configure_command = "configure %s"
})
```
The parameters are as follows:
```
    available_presets:      function( cwd )
                                cwd: Neovim's current working directory
                                return: a list of strings
    default_preset:         string
                                Pretty self-explanatory.
                                Used if nothing is explicitly selected.
    build_command:          string
                                Formatted using string.format( build_command, selected_preset )
    configure_command:      string
                                Formatted using string.format( configure_command, selected_preset )
```

#### Example mappings
```lua
-- larry
nvim_set_keymap("n", "<leader>P", "<CMD>SelectPreset<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>C", "<CMD>Configure<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>c", "<CMD>ToggleConfigureView<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>B", "<CMD>Build<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>b", "<CMD>ToggleBuildView<CR>", { noremap = true })
```

### Usage
* Select a preset (or live with your default setting) using the `SelectPreset` command and/or Larry's exposed `SelectPreset()` function.
* Invoke either `Configure` or `Build` using the commands, or through the lua functions, e.g. `require("larry").Configure()`.
* View the outputs of `Configure` and `Build` using the `ToggleConfigureView` and `ToggleBuildView` commands (also available in lua). These buffers follow the output of the command, and clear if you rerun `Configure`/`Build`

There is also a `GetSelectedPreset` command (and lua function) that does what it says on the can.


## Roadmap

In no particular order:

- [ ] Goto file/line on compilation errors   
- [ ] Colors in Configure View   
- [ ] Colors in Build View   
- [ ] Functionality for getting the current compilation target, and what progress it's at   
- [ ] Display current preset in the status line?   
