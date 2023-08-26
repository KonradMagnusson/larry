local Module = {}

Module.config = {
	available_presets = function( cwd ) return "" end,
	selected_preset = "release",
	build_command = "build %s",
	configure_command = "configure %s",
}

local _jobs = {
	configure = nil,
	build = nil
}

local _buffers = {
	stack = {},
	configure = -1,
	build = -1
}

local function _info( msg ) vim.notify( msg, vim.log.levels.INFO ) end
local function _warn( msg ) vim.notify( msg, vim.log.levels.WARN ) end
local function _error( msg ) vim.notify( msg, vim.log.levels.ERROR ) end


Module.SelectPreset = function()
	local Presets = { "release", "debug", "release-lto", "debug-Og" }
	-- TODO: get presets from available_presets

	vim.ui.select(Presets, { prompt = "Select preset: " },
		function(Preset)
			Module.config.selected_preset = Preset
		end
	)
	vim.notify( "Selected preset " .. Module.config.selected_preset, vim.log.levels.INFO)
end


Module.ToggleConfigureView = function()
	local configure_buf = _buffers.configure

	if configure_buf == -1 then
		_error( "Failed to toggle configure view: setup() has not been invoked yet!" )
		return
	end

	local set_buf = vim.api.nvim_set_current_buf

	local cur_buf = vim.api.nvim_get_current_buf()
	local prev_buf = _buffers.stack[#_buffers.stack]

	if cur_buf == configure_buf then
		if prev_buf == nil then
			_error( "Failed to toggle configure view: No other buffer was open!?" )
			return
		end
		set_buf(prev_buf)
		table.remove( _buffers.stack, #_buffers.stack )
		return
	end

	-- Is the configure buffer already on the stack?
	-- Remove it and set it as active.
	for idx, tab in pairs( _buffers.stack ) do
		if tab == configure_buf then
			table.remove( _buffers.stack, idx )
			set_buf( configure_buf )
			return
		end
	end

	table.insert( _buffers.stack, cur_buf )
	set_buf( _buffers.configure )
end


Module.ToggleBuildView = function()
	local build_buf = _buffers.build

	if build_buf == -1 then
		_error( "Failed to toggle build view: setup() has not been invoked yet!" )
		return
	end

	local set_buf = vim.api.nvim_set_current_buf

	local cur_buf = vim.api.nvim_get_current_buf()
	local prev_buf = _buffers.stack[#_buffers.stack]

	if cur_buf == build_buf then
		if prev_buf == nil then
			_error( "Failed to toggle build view: No other buffer was open!?" )
			return
		end
		set_buf(prev_buf)
		table.remove( _buffers.stack, #_buffers.stack )
		return
	end

	-- Is the build buffer already on the stack?
	-- Remove it and set it as active.
	for idx, tab in pairs( _buffers.stack ) do
		if tab == build_buf then
			table.remove( _buffers.stack, idx )
			set_buf( build_buf )
			return
		end
	end

	table.insert( _buffers.stack, cur_buf )
	set_buf( _buffers.build )
end


Module.Configure = function()
	if _jobs.configure ~= nil then
		_error( "Configure in progress!" )
		return
	end

	_info( "Running configure..." )
	local buf = _buffers.configure

	local on_stdout = function( _, data, _ )
		for _, line in pairs(data) do
			if line ~= "" then
				vim.api.nvim_buf_set_option( buf, "modifiable", true )
				vim.fn.appendbufline( buf, "$", line )
				vim.api.nvim_buf_set_option( buf, "modifiable", false )
			end
		end

		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_buf_set_option( buf, "modified", false )
			vim.cmd( "normal! G" )
		end
	end
	local on_exit = function( _, exit_code, _ )
		_jobs.configure = nil
		if exit_code  ~= 0 then
			_error( "Configure failed!" )
			return
		end
		_info( "Configure done!" )
	end

	vim.api.nvim_buf_set_option( buf, "modifiable", true )
	vim.api.nvim_buf_call( _buffers.configure, function( _ ) vim.cmd( "normal! ggdG" ) end )
	vim.api.nvim_buf_set_option( buf, "modifiable", false )
	_jobs.configure = vim.fn.jobstart(
		Module.config.configure_command,
		{
			detach = false, -- TODO: this could be nice to have true at some point in the future
			on_stdout = on_stdout,
			on_stderr = on_stdout,
			on_exit = on_exit
		})
	-- Can't vim.fn.jobwait here, because that blocks the rest of neovim.
	-- TODO: call this shit async, so that we can wait and do things properly
end



Module.Build = function()
	if _jobs.build ~= nil then
		_error( "Build in progress!" )
		return
	end

	_info( "Running build..." )
	local buf = _buffers.build

	local on_stdout = function( _, data, _ )
		for _, line in pairs(data) do
			if line ~= "" then
				vim.api.nvim_buf_set_option( buf, "modifiable", true )
				vim.fn.appendbufline( buf, "$", line )
				vim.api.nvim_buf_set_option( buf, "modifiable", false )
			end
		end

		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_buf_set_option( buf, "modified", false )
			vim.cmd( "normal! G" )
		end
	end
	local on_exit = function( _, exit_code, _ )
		_jobs.build = nil
		if exit_code  ~= 0 then
			_error( "Build failed!" )
			return
		end
		_info( "Build done!" )
	end

	vim.api.nvim_buf_set_option( buf, "modifiable", true )
	vim.api.nvim_buf_call( _buffers.build, function( _ ) vim.cmd( "normal! ggdG" ) end )
	vim.api.nvim_buf_set_option( buf, "modifiable", false )
	_jobs.build = vim.fn.jobstart(
		Module.config.build_command,
		{
			detach = false, -- TODO: this could be nice to have true at some point in the future
			on_stdout = on_stdout,
			on_stderr = on_stdout,
			on_exit = on_exit
		})
	-- Can't vim.fn.jobwait here, because that blocks the rest of neovim.
	-- TODO: call this shit async, so that we can wait and do things properly
end

Module.setup = function( config )
	Module.config = vim.tbl_deep_extend( "force", {}, Module.config, config or {} )
	_buffers.configure = vim.api.nvim_create_buf( false, false )
	vim.api.nvim_buf_set_name( _buffers.configure, "larry_configure" )
	vim.api.nvim_buf_set_option( _buffers.configure, "buftype", "nowrite" )
	vim.api.nvim_buf_set_option( _buffers.configure, "scrollback", 1000 )

	_buffers.build = vim.api.nvim_create_buf( false, false )
	vim.api.nvim_buf_set_name( _buffers.build, "larry_build" )
	vim.api.nvim_buf_set_option( _buffers.build, "buftype", "nowrite" )
	vim.api.nvim_buf_set_option( _buffers.build, "scrollback", 10000 )
end



return Module
