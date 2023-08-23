local Module = {}

Module.defaults = {
	available_presets = function() return "" end,
	selected_preset = "release",
	build_command = "build %s",
	configure_command = "configure %s",
}




Module.SelectPreset = function()
	local Presets = { "release", "debug", "release-lto", "debug-Og" }
	-- TODO: get presets from available_presets

	vim.ui.select(Presets, { prompt = "Select preset: " },
		function(Preset)
			Module.defaults.selected_preset = Preset
		end
	)
	vim.notify( "Selected preset " .. Module.defaults.selected_preset, vim.log.levels.INFO)
end


Module.Configure = function()
	local ConfigureCmd = string.format( Module.defaults.configure_command, Module.defaults.selected_preset )

	local ConfigureTerm = require( "toggleterm.terminal" ).Terminal:new({
	  cmd = ConfigureCmd,
	  direction = "float",
	  close_on_exit = false,
	  auto_scroll = true,
	  on_create = function( Term )
		vim.notify( "Configuring " .. Module.defaults.selected_preset, vim.log.levels.INFO )
		Term.display_name = "Configure Terminal"
		Term:open()
	  end,
	  on_exit = function( Term, Job, ExitCode, Name )
		if ExitCode == 0 then
			vim.notify( "Configure succeeded!", vim.log.levels.INFO )
			Term:close()
			return
		else
			vim.notify( "Configure failed!", vim.log.levels.ERROR )
		end
	  end
	})

	ConfigureTerm:spawn()
end



Module.Build = function()
	local BuildCmd = string.format( Module.defaults.build_command, Module.defaults.selected_preset )

	local BuildTerm = require( "toggleterm.terminal" ).Terminal:new({
	  cmd = BuildCmd,
	  direction = "float",
	  close_on_exit = false,
	  auto_scroll = true,
	  on_create = function( Term )
		vim.notify( "Building " .. Module.defaults.selected_preset, vim.log.levels.INFO )
		Term.display_name = "Build Terminal"
		Term:open()
	  end,
	  on_exit = function( Term, Job, ExitCode, Name )
		if ExitCode == 0 then
			vim.notify( "Build succeeded!", vim.log.levels.INFO )
			Term:close()
			return
		else
			vim.notify( "Build failed!", vim.log.levels.ERROR )
		end
	  end
	})

	BuildTerm:spawn()
end





Module.setup = function( config )
	Module.defaults = vim.tbl_deep_extend( "force", {}, Module.defaults, config or {} )
end



return Module
