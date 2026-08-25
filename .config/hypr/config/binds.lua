local mainMod = "SUPER"
local noctCall = "noctalia msg "

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))
