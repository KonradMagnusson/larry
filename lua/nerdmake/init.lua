local Module = {}

Module.defaults = {
	available_presets = function() return "" end
}





Module.SelectPreset = function()
	vim.notify( "Selecting preset!" .. Module.defaults.available_presets(), vim.log.levels.INFO )
end


Module.Configure = function()
	vim.notify( "Configure!" .. Module.defaults.available_presets(), vim.log.levels.INFO )
end


Module.Build = function()
	vim.notify( "Build!" .. Module.defaults.available_presets(), vim.log.levels.INFO )
end





Module.setup = function( config )
	Module.defaults = vim.tbl_deep_extend( "force", {}, Module.defaults, config or {} )
end



return Module
