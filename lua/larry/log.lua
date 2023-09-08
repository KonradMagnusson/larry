local Log = {}

local make_log_fn = function( msg_icon, loglevel )
						return function( msg, timeout, replace )
							return vim.notify( msg, loglevel,
													{
														title = "Larry",
														icon = msg_icon,
														timeout = timeout,
														replace = replace
													})
						end
					end

Log.build_info = make_log_fn( "󰣪", vim.log.levels.INFO )
Log.build_warn = make_log_fn( "󰣪", vim.log.levels.WARN )
Log.build_error = make_log_fn( "󰣪", vim.log.levels.ERROR )

Log.configure_info = make_log_fn( "󰒓", vim.log.levels.INFO )
Log.configure_warn = make_log_fn( "󰒓", vim.log.levels.WARN )
Log.configure_error = make_log_fn( "󰒓", vim.log.levels.ERROR )

return Log
