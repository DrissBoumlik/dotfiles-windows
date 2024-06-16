-- WARNING:  This file gets overwritten by the 'flexprompt configure' wizard!
--
-- If you want to make changes, consider copying the file to
-- 'flexprompt_config.lua' and editing that file instead.

flexprompt = flexprompt or {}
flexprompt.settings = flexprompt.settings or {}
flexprompt.settings.charset = "unicode"
flexprompt.settings.connection = "solid"
flexprompt.settings.flow = "concise"
flexprompt.settings.frame_color =
{
    "brightblack",
    "brightblack",
    "darkwhite",
    "darkblack",
}
flexprompt.settings.heads = "pointed"
flexprompt.settings.left_frame = "round"
-- flexprompt.settings.left_prompt = "{battery}{break}{user:color=cyan:type=user}{break}{histlabel}{cwd:type=folder}{break}{git:color=red:staged=orange}"
flexprompt.settings.left_prompt = "{histlabel}{cwd:type=smart}{break}{git:color=red:nostaged:noaheadbehind:counts}{break}{npm:smartname}"
flexprompt.settings.lines = "two"
flexprompt.settings.nerdfonts_version = 3
flexprompt.settings.nerdfonts_width = 1
flexprompt.settings.powerline_font = true
flexprompt.settings.right_frame = "none"
flexprompt.settings.right_prompt = "{overtype}{exit:color=red}{duration}{break}{time:color=brightyellow:format=%a %d/%m %H:%M}{break}{admin}"
flexprompt.settings.separators = "pointed"
flexprompt.settings.spacing = "normal"
flexprompt.settings.style = "rainbow"
flexprompt.settings.symbols =
{
    prompt = "❯",
}
flexprompt.settings.tails = "pointed"
flexprompt.settings.use_icons = true
