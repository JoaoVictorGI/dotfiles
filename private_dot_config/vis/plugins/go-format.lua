vis:option_register("go_fmt_binary", "string", function(value, toogle)
	vis.win.go_fmt_binary = value
	return true
end, "Binary to format Go code on save")

local function gofmt(file, path)
	local win = vis.win
	if win.syntax ~= "go" then
		return true
	end

	local fmt = "gofmt"
	if vis.win.go_fmt_binary then
		fmt = vis.win.go_fmt_binary
	end

	local pos = win.selection.pos
	local status, out, err = vis:pipe(file, { start = 0, finish = file.size }, fmt)
	if status ~= 0 or not out then
		if err then
			vis:info(err)
		end
		return false
	end

	file:delete(0, file.size)
	file:insert(0, out)
	win.selection.pos = pos
	return true
end

vis.events.subscribe(vis.events.FILE_SAVE_PRE, gofmt)
