local Module = {}

local log = require("larry.log")

Module.config = {
	available_presets = function( cwd ) return {} end,
	default_preset = "release",
	build_command = "build %s",
	configure_command = "configure %s",
	notification_timeout = 5000
}

local _state = {
	jobs = {
		configure = nil,
		build = nil
	},

	buffers = {
		stack = {},
		configure = -1,
		build = -1
	},

	buildstatus = {
		percent = nil,
		target = nil
	},

	has_terminal_plugin = false,
}


Module.GetBuildStatusPerc = function()
	return _state.buildstatus.percent
end
Module.GetBuildStatusTarget = function()
	return _state.buildstatus.target
end


Module.GetSelectedPreset = function()
	if vim.g.LARRY_SELECTED_PRESET ~= nil then
		return vim.g.LARRY_SELECTED_PRESET
	end
	return Module.config.default_preset
end

Module.SelectPreset = function()
	local presets = Module.config.available_presets( vim.fn.getcwd() )

	if #presets == 0 then
		log.error( "No presets available! Was setup() called?" )
		return
	end

	local apply_selection = function( preset )
		log.info( "Selected preset " .. preset)
		vim.g.LARRY_SELECTED_PRESET = preset
	end

	vim.ui.select( presets, { prompt = "Select preset: " }, apply_selection )
end


Module.ToggleConfigureView = function()
	local configure_buf = _state.buffers.configure

	if configure_buf == -1 then
		log.configure_error( "Failed to toggle configure view: setup() has not been invoked yet!" )
		return
	end

	local set_buf = vim.api.nvim_set_current_buf

	local cur_buf = vim.api.nvim_get_current_buf()
	local prev_buf = _state.buffers.stack[#_state.buffers.stack]

	if cur_buf == configure_buf then
		if prev_buf == nil then
			log.configure_error( "Failed to toggle configure view: No other buffer was open!?" )
			return
		end
		set_buf(prev_buf)
		table.remove( _state.buffers.stack, #_state.buffers.stack )
		return
	end

	-- Is the configure buffer already on the stack?
	-- Remove it and set it as active.
	for idx, tab in pairs( _state.buffers.stack ) do
		if tab == configure_buf then
			table.remove( _state.buffers.stack, idx )
			set_buf( configure_buf )
			return
		end
	end

	table.insert( _state.buffers.stack, cur_buf )
	set_buf( _state.buffers.configure )
end


Module.ToggleBuildView = function()
	local build_buf = _state.buffers.build

	if build_buf == -1 then
		log.error( "Failed to toggle build view: setup() has not been invoked yet!" )
		return
	end

	local set_buf = vim.api.nvim_set_current_buf

	local cur_buf = vim.api.nvim_get_current_buf()
	local prev_buf = _state.buffers.stack[#_state.buffers.stack]

	if cur_buf == build_buf then
		if prev_buf == nil then
			log.build_error( "Failed to toggle build view: No other buffer was open!?" )
			return
		end
		set_buf(prev_buf)
		table.remove( _state.buffers.stack, #_state.buffers.stack )
		return
	end

	-- Is the build buffer already on the stack?
	-- Remove it and set it as active.
	for idx, tab in pairs( _state.buffers.stack ) do
		if tab == build_buf then
			table.remove( _state.buffers.stack, idx )
			set_buf( build_buf )
			return
		end
	end

	table.insert( _state.buffers.stack, cur_buf )
	set_buf( _state.buffers.build )
end


Module.Configure = function()
	if _state.jobs.configure ~= nil then
		log.configure_error( "Configure in progress!" )
		return
	end

	local configuring_notification = log.configure_info( "Configuring " .. Module.GetSelectedPreset() )
	local buf = _state.buffers.configure

	local on_stdout = function( _, data, _ )
		for _, line in pairs(data) do
			if line ~= "" then
				if _state.has_terminal_plugin then
					line = string.sub(line, 0, #line - 1)
				end
				vim.api.nvim_buf_set_option( buf, "modifiable", true )
				vim.fn.appendbufline( buf, "$", line )
				vim.api.nvim_buf_set_option( buf, "modifiable", false )
			end
		end

		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_buf_set_option( buf, "modified", false )
			vim.cmd( "keepjumps normal! G" )
		end
	end
	local on_exit = function( _, exit_code, _ )
		_state.jobs.configure = nil
		if exit_code  ~= 0 then
			log.configure_error( "Configure failed!", Module.config.notification_timeout, configuring_notification )
			return
		end
		log.configure_info( "Configure done!", Module.config.notification_timeout, configuring_notification )
	end

	vim.api.nvim_buf_set_option( buf, "modifiable", true )
	vim.api.nvim_buf_call( _state.buffers.configure, function( _ ) vim.cmd( "keepjumps normal! ggdG" ) end )
	vim.api.nvim_buf_set_option( buf, "modifiable", false )

	_state.jobs.configure = vim.fn.jobstart(
		string.format( Module.config.configure_command, Module.GetSelectedPreset() ),
		{
			detach = false, -- TODO: this could be nice to have true at some point in the future
			pty = _state.has_terminal_plugin,
			on_stdout = on_stdout,
			on_stderr = on_stdout,
			on_exit = on_exit
		})
end



Module.Build = function()
	if _state.jobs.build ~= nil then
		log.build_error( "Build in progress!" )
		return
	end

	local build_notification = log.build_info( "Building " .. Module.GetSelectedPreset(), false )

	local buf = _state.buffers.build

	local update_build_state = function( line )
		local percentage, target = string.match(line, "%[%s+(%d+)%%%].*/(.*%.o)")
		if percentage ~= nil and string.len( percentage ) >= 1 then
			_state.buildstatus.percent = percentage
		end

		if target ~= nil and string.len( target ) >= 1 then
			_state.buildstatus.target = target
		end
	end

	local on_stdout = function( _, data, _ )
		for _, line in pairs(data) do
			if line ~= "" then
				vim.api.nvim_buf_set_option( buf, "modifiable", true )
				if _state.has_terminal_plugin then
					line = string.sub(line, 0, #line - 1)
				end
				vim.fn.appendbufline( buf, "$", line )
				vim.api.nvim_buf_set_option( buf, "modifiable", false )
				update_build_state( line )
			end
		end

		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_buf_set_option( buf, "modified", false )
			vim.cmd( "keepjumps normal! G" )
		end
	end
	local on_exit = function( _, exit_code, _ )
		_state.jobs.build = nil
		if exit_code  ~= 0 then
			log.build_error( "Build failed!", Module.config.notification_timeout, build_notification  )
			return
		end
		log.build_info( "Build finished!", Module.config.notification_timeout, build_notification )
	end

	vim.api.nvim_buf_set_option( buf, "modifiable", true )
	vim.api.nvim_buf_call( _state.buffers.build, function( _ ) vim.cmd( "keepjumps normal! ggdG" ) end )
	vim.api.nvim_buf_set_option( buf, "modifiable", false )

	_state.jobs.build = vim.fn.jobstart(
		string.format( Module.config.build_command, Module.GetSelectedPreset() ),
		{
			detach = false, -- TODO: this could be nice to have true at some point in the future
			pty = _state.has_terminal_plugin,
			on_stdout = on_stdout,
			on_stderr = on_stdout,
			on_exit = on_exit
		})
end


local _find_or_create_buffer = function( name )
	local buf = vim.fn.bufadd( name )
	vim.fn.bufload( buf )
	vim.api.nvim_buf_set_option( buf, "buftype", "nowrite" )
	vim.api.nvim_buf_set_option( buf, "modifiable", false )
	return buf
end

Module.setup = function( config )
	Module.config = vim.tbl_deep_extend( "force", {}, Module.config, config or {} )

	_state.buffers.configure = _find_or_create_buffer( "larry_configure" )
	_state.buffers.build = _find_or_create_buffer( "larry_build" )

	_state.has_terminal_plugin, _ = pcall(require, "terminal")

	if _state.has_terminal_plugin then
		vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
			callback = function( _ )
				local bufname = vim.api.nvim_buf_get_name(0)
				local bikeshed = vim.fn.split(bufname, '/', false)
				bufname = bikeshed[#bikeshed]
				if bufname == "larry_build" or bufname == "larry_configure" then
					require("terminal").setup()
					vim.cmd("setl filetype=terminal")
				end
			end
		})
	end
end



return Module
