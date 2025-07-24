script_name = "点灭特效生成"
script_description = "指定间隔闪烁"
script_author = "dtlnor"
script_version = "1.0"

--- The function called when the user selects the menu item. Returns new selected_lines and active_line.
--- @param subtitles Subtitles
--- @param selected_lines table
--- @param active_line number
--- @return table|nil, number|nil
function flickerline(subtitles, selected_lines, active_line)
	--- @type DialogControl[]
	dialog_config =	{
		{class="label",x=2,y=0,width=1,height=1,label="间隔:"},
		{class="intedit",name="intval_ms",x=3,y=0,width=1,min=1,height=1,value="50"},
		{class="label",x=2,y=1,width=1,height=1,label="渐变持续时间(必须小于间隔):"},
		{class="intedit",name="fade_dur_ms",x=3,y=1,width=1,min=0,height=1,value="0"},
	}
	button, result_table = aegisub.dialog.display(dialog_config)
	if not button then
		return
	end

	local intval_ms = result_table.intval_ms
	local fade_dur_ms = result_table.fade_dur_ms
	if fade_dur_ms >= intval_ms then
		aegisub.log("Fade duration must be less than flick interval.\n")
		return
	end
	
	for item_i, target_line in pairs(selected_lines) do
		--- @type DialogueLine
		local process_line = subtitles[target_line]
		-- I know this must be a dialogue line, but let's check just in case.
		if process_line.class ~= "dialogue" then
			aegisub.log("Line " .. target_line .. " is not a dialogue line, skipping.\n")
			goto continue
		end
		local total_time_ms = process_line.end_time - process_line.start_time
		if total_time_ms <= 0 then
			aegisub.log("Line " .. target_line .. " has no duration, skipping.\n")
			goto continue
		end

		local out = ""
		for i = 0, math.floor(total_time_ms / intval_ms / 2) - 1 do
			local offset = i * 2 * intval_ms
			out = out .. string.format("\\t(%d,%d,\\alpha0)\\t(%d,%d,\\alphaFF)", offset, offset + fade_dur_ms, offset + intval_ms, offset + intval_ms + fade_dur_ms)
		end
		process_line.text = "{" .. out .. "}" .. process_line.text
		subtitles[target_line] = process_line
		::continue::
	end

end

aegisub.register_macro(script_name, script_description, flickerline)