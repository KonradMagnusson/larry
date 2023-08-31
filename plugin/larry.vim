if exists( "g:larry_loaded" )
	finish
endif
let g:larry_loaded = 1

command! -nargs=0 LarrySelectPreset lua require("larry").SelectPreset()
command! -nargs=0 LarryGetSelectedPreset lua require("larry").GetSelectedPreset()

command! -nargs=0 LarryConfigure lua require("larry").Configure()
command! -nargs=0 LarryBuild lua require("larry").Build()

command! -nargs=0 LarryToggleConfigureView lua require("larry").ToggleConfigureView()
command! -nargs=0 LarryToggleBuildView lua require("larry").ToggleBuildView()
