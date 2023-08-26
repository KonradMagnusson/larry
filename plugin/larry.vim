if exists( "g:larry_loaded" )
	finish
endif
let g:larry_loaded = 1

command! -nargs=0 SelectPreset lua require("larry").SelectPreset()
command! -nargs=0 Configure lua require("larry").Configure()
command! -nargs=0 Build lua require("larry").Build()

command! -nargs=0 ToggleConfigureView lua require("larry").ToggleConfigureView()
command! -nargs=0 ToggleBuildView lua require("larry").ToggleBuildView()
