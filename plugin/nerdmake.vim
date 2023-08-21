

if exists( "g:nerdmake_loaded" )
	finish
endif
let g:nerdmake_loaded = 1



let s:nerdmake_default_preset = "linux-clang-DebugOpt"
let s:nerdmake_selected_preset = ""


command! -nargs=0 SelectPreset lua require("nerdmake").SelectPreset()
command! -nargs=0 Configure lua require("nerdmake").Configure()
command! -nargs=0 Build lua require("nerdmake").Build()
