# Larry
## What?
A quick and dirty hack to invoke CMake-like build systems from Neovim.   
**Disclaimer:** I don't quite know what I'm doing; this has been a learning experience.

## Why?
Because switching to a different terminal to do things is a hassle.

## How?
### Installation

E.g. using [Lazy](https://github.com/folke/lazy.nvim):   
```lua
{
    "konradmagnusson/larry",
    dependencies = {
        "rcarriga/nvim-notify", -- optional. Enables nicer notifications.
        "norcalli/nvim-terminal.lua", -- optional. Enables ASCII color code support in the build/configure views.
    }
    opts = {
        available_presets = function( cwd )
                return { "release", "debug" }
            end,
        default_preset = "release",
        build_command = "build %s",
        configure_command = "configure %s"
    }
}
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
nvim_set_keymap("n", "<leader>lP", "<CMD>LarrySelectPreset<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>lC", "<CMD>LarryConfigure<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>lc", "<CMD>LarryToggleConfigureView<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>lB", "<CMD>LarryBuild<CR>", { noremap = true })
nvim_set_keymap("n", "<leader>lb", "<CMD>LarryToggleBuildView<CR>", { noremap = true })
```

### Usage
* Select a preset (or live with your default setting) using the `LarrySelectPreset` command and/or Larry's exposed `SelectPreset()` function.
* Invoke either `LarryConfigure` or `LarryBuild` using the commands, or through the lua functions, e.g. `require("larry").Configure()`.
* View the outputs of `LarryConfigure` and `LarryBuild` using the `LarryToggleConfigureView` and `LarryToggleBuildView` commands (similarly available in lua). These buffers follow the output of the command, and clear if you rerun `LarryConfigure`/`LarryBuild`

There is also a `LarryGetSelectedPreset` command (and lua function) that does what it says on the can.


## Roadmap

In no particular order:

- [ ] Goto file/line on compilation errors   
- [x] Colors in Configure View   
- [x] Colors in Build View   
- [ ] Functionality for getting the current compilation target, and what progress it's at, e.g. for use in |statusline|   
- [ ] Display current preset in the status line?   
