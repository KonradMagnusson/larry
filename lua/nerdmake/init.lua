local Module = {}

Module.defaults = {
	available_presets = function() return "" end,
	selected_preset = "some_default_cmake_preset",
}





Module.SelectPreset = function()
	vim.notify( "Selecting preset!", vim.log.levels.INFO )
end


Module.Configure = function()
	vim.notify( "Configuring " .. Module.defaults.selected_preset, vim.log.levels.INFO )
end


Module.Build = function()
	vim.notify( "Building " .. Module.defaults.selected_preset, vim.log.levels.INFO )

	-- TODO: Ensure the output ends up being visible somewhere - that could prove useful...
	--vim.fn.systemlist("docker run --rm -t success")
	vim.fn.systemlist("docker run --rm -t fail")

	if vim.v.shell_error == 0 then
		vim.notify( "Success!", vim.log.levels.INFO )
	else
		vim.notify( "Build failed!", vim.log.levels.ERROR )
	end
end





Module.setup = function( config )
	Module.defaults = vim.tbl_deep_extend( "force", {}, Module.defaults, config or {} )
end



return Module
