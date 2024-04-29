M = {}
M.csep = "|"
M.rsep = "-"
M.xsep = "+"
M.npad = 1
M.ndec = 2

local function esc(str)
	return str:gsub("%p", "%%%1")
end

local function isrow(line)
	local match = line:match("^%s*" .. esc(M.csep))
	if match then
		return 1
	else
		return
	end
end

local function isdiv(line)
	local match = line:match("^%s*" .. esc(M.csep .. M.rsep))
	if match then
		return 1
	else
		return
	end
end

local function switch(tbl, row1, col1, row2, col2)
	local tmp = tbl[row1][col1]
	tbl[row1][col1] = tbl[row2][col2]
	tbl[row2][col2] = tmp
	return tbl
end

local function getlines()
	return vis.win.file.lines, vis.win.selection.line, vis.win.selection.col
end

local function gettable(ln, lc, lines)
	local tbl = {}

	-- Table range --
	tbl.start = ln
	tbl.finish = ln

	for i = ln - 1, 1, -1 do
		if not isrow(lines[i]) then
			break
		end
		tbl.start = tbl.start - 1
	end
	for i = ln + 1, #lines do
		if not isrow(lines[i]) then
			break
		end
		tbl.finish = tbl.finish + 1
	end

	-- Table content --
	for i = tbl.start, tbl.finish do
		local fields = {}
		local row = lines[i]
		row = row:gsub("^%s*(.-)%s*$", "%1")
		for s in row:gmatch("[^" .. esc(M.csep) .. "]+") do
			s = s:match("%S") and s:gsub("^%s*(.-)%s*$", "%1") or " "
			table.insert(fields, s)
		end
		tbl[i - tbl.start + 1] = fields
	end

	-- Total number of table columns --
	tbl.ncols = 0
	for i, c in ipairs(tbl) do
		if #c > tbl.ncols then
			tbl.ncols = #c
		end
	end

	-- Total number of table rows --
	tbl.nrows = tbl.finish - tbl.start + 1

	-- Current table column --
	local ci = 1
	tbl.icol = 0
	for _, c in utf8.codes(lines[ln]) do
		local uc = utf8.char(c)
		if (uc == M.csep or (isdiv(lines[ln]) and uc == M.xsep)) and lc > ci then
			tbl.icol = tbl.icol + 1
		end
		ci = ci + 1
	end

	-- Current table row --
	tbl.irow = ln - tbl.start + 1

	return tbl
end

local function printtable(tbl, lines)
	tbl.indent = lines[tbl.start]:match("^%s*")
	tbl.colw = {}

	for c = 1, tbl.ncols do
		local max = 0
		for r = 1, tbl.nrows do
			if not tbl[r][c] then
				tbl[r][c] = " "
			end
			if not isdiv(lines[tbl.start + r - 1]) and utf8.len(tbl[r][c]) > max then
				max = utf8.len(tbl[r][c])
			end
		end
		tbl.colw[c] = (max == 0 and 1 or max)
	end

	for i = tbl.start, tbl.finish do
		local rowfmt = M.csep
		if tbl.ncols == 0 then
			tbl.colw[1] = 1
			rowfmt = ("%s%s %s%s"):format(rowfmt, (" "):rep(M.npad), (" "):rep(M.npad), M.csep)
		end

		local r = tbl[i - tbl.start + 1]
		for c = 1, #r do
			local cellfmt
			if isdiv(lines[i]) then
				rowfmt = ("%s%s%s"):format(
					rowfmt,
					M.rsep:rep(M.npad * 2 + tbl.colw[c]),
					c < tbl.ncols and M.xsep or M.csep
				)
			else
				if not tonumber(r[c]) then
					cellfmt = ("%%-%ss"):format(tbl.colw[c])
				elseif tonumber(r[c]) % 1 == 0 then
					cellfmt = ("%%%sd"):format(tbl.colw[c])
				else
					cellfmt = ("%%%s.%sf"):format(tbl.colw[c], M.ndec)
				end
				rowfmt = ("%s%s%s%s%s"):format(rowfmt, (" "):rep(M.npad), cellfmt, (" "):rep(M.npad), M.csep)
			end

			-- Fix padding for cells with UTF-8 characters --
			if utf8.len(r[c]) < tbl.colw[c] then
				r[c] = r[c] .. (" "):rep(tbl.colw[c] - utf8.len(r[c]))
			end
		end
		lines[i] = tbl.indent .. rowfmt:format(table.unpack(r))
	end
end

local function newrow(tbl, ln, lines)
	local row = M.csep
	local i = 1
	repeat
		row = row .. (" "):rep(tbl.colw[i] + (M.npad * 2)) .. M.csep
		i = i + 1
	until i > #tbl.colw

	vis.win.selection:to(ln, 1)
	vis.win.file:insert(vis.win.selection.pos + #lines[ln] + 1, tbl.indent .. row .. "\n")
end

local function gotocell(tbl, lines, row, col)
	local pos
	local icol = 0
	local i = 1
	local line = lines[tbl.start + row - 1]

	for _, c in utf8.codes(line) do
		local uc = utf8.char(c)
		if icol == col then
			local mc = uc:match("%S")
			pos = pos and pos or i + M.npad
			if mc then
				pos = mc == M.csep and pos or i
				break
			end
		end
		if uc == M.csep then
			icol = icol + 1
		end
		i = i + 1
	end
	vis.win.selection:to(tbl.start + row - 1, pos)
end

local function nextcell()
	local lines, ln, lc = getlines()

	if not isrow(lines[ln]) then
		vis:feedkeys("<vis-insert-tab>")
		return
	end

	local tbl = gettable(ln, lc, lines)
	local bot = tbl.finish

	printtable(tbl, lines)

	for i = tbl.finish, tbl.start, -1 do
		bot = i - tbl.start + 1
		if not isdiv(lines[i]) then
			break
		end
	end

	if tbl.icol >= tbl.ncols or isdiv(lines[ln]) then
		if tbl.irow == tbl.nrows or tbl.irow >= bot then
			newrow(tbl, ln, lines)
		end
		local skip = 1
		while isdiv(lines[ln + skip]) do
			skip = skip + 1
		end
		gotocell(tbl, lines, tbl.irow + skip, 1)
	else
		gotocell(tbl, lines, tbl.irow, tbl.icol + 1)
	end
end

local function prevcell()
	local lines, ln, lc = getlines()

	if not isrow(lines[ln]) then
		return
	end

	local tbl = gettable(ln, lc, lines)
	local top = tbl.start

	printtable(tbl, lines)

	for i = tbl.start, tbl.finish do
		top = i - tbl.start + 1
		if not isdiv(lines[i]) then
			break
		end
	end

	if tbl.icol <= 1 or isdiv(lines[ln]) then
		if tbl.irow == 1 or tbl.irow <= top then
			vis:info("No previous cells")
			gotocell(tbl, lines, top, 1)
		else
			local skip = 1
			while isdiv(lines[ln - skip]) do
				skip = skip + 1
			end
			gotocell(tbl, lines, tbl.irow - skip, tbl.ncols)
		end
	else
		gotocell(tbl, lines, tbl.irow, tbl.icol - 1)
	end
end

local function movecell(ir, ic)
	local lines, ln, lc = getlines()

	if not isrow(lines[ln]) or isdiv(lines[ln]) then
		if ir == 0 and ic == -1 then
			vis:feedkeys("<vis-motion-codepoint-prev>")
		elseif ir == 1 and ic == 0 then
			vis:feedkeys("<vis-motion-screenline-down>")
		elseif ir == -1 and ic == 0 then
			vis:feedkeys("<vis-motion-screenline-up>")
		elseif ir == 0 and ic == 1 then
			vis:feedkeys("<vis-motion-codepoint-next>")
		end
		return
	end
	local tbl = gettable(ln, lc, lines)

	local skip = 1
	if ir ~= 0 then
		while isdiv(lines[ln + (skip * ir)]) do
			skip = skip + 1
		end
	end

	local nr = tbl.irow + (ir * skip)
	local nc = tbl.icol + ic

	if tbl.icol == 0 or tbl.icol > tbl.ncols then
		vis:info("Not a table cell")
		return
	elseif not tbl[nr] or not tbl[nr][nc] then
		vis:info("Table limit reached")
		return
	end

	switch(tbl, tbl.irow, tbl.icol, nr, nc)
	printtable(tbl, lines)
	gotocell(tbl, lines, nr, nc)
end

local function movecolumn(ic)
	local lines, ln, lc = getlines()

	if not isrow(lines[ln]) then
		vis:feedkeys("<vis-selections-remove-column-except>")
		return
	end
	local tbl = gettable(ln, lc, lines)

	local nr = tbl.irow
	local nc = tbl.icol + ic

	if isdiv(lines[ln]) then
		local skip = 1
		while isdiv(lines[ln + skip]) do
			skip = skip + 1
		end
		nr = tbl.irow + skip
	end

	if tbl.icol == 0 or tbl.icol > tbl.ncols then
		vis:info("Not a table column")
		return
	elseif nc == 0 or nc > tbl.ncols then
		vis:info("Table limit reached")
		return
	end

	for i = 1, tbl.nrows do
		switch(tbl, i, tbl.icol, i, nc)
	end

	printtable(tbl, lines)
	gotocell(tbl, lines, nr, nc)
end

vis:option_register("tablemode", "bool", function(value, toggle)
	if not vis.win then
		return false
	end
	vis.win.tablemode = toggle and not vis.win.tablemode or value
	if vis.win.tablemode then
		vis.win:map(vis.modes.NORMAL, "<Tab>", nextcell)
		vis.win:map(vis.modes.INSERT, "<Tab>", nextcell)
		vis.win:map(vis.modes.NORMAL, "<S-Tab>", prevcell)
		vis.win:map(vis.modes.INSERT, "<S-Tab>", prevcell)
		vis.win:map(vis.modes.NORMAL, "<C-h>", function()
			movecolumn(-1)
		end)
		vis.win:map(vis.modes.NORMAL, "<C-l>", function()
			movecolumn(1)
		end)
		vis.win:map(vis.modes.NORMAL, "gh", function()
			movecell(0, -1)
		end)
		vis.win:map(vis.modes.NORMAL, "gj", function()
			movecell(1, 0)
		end)
		vis.win:map(vis.modes.NORMAL, "gk", function()
			movecell(-1, 0)
		end)
		vis.win:map(vis.modes.NORMAL, "gl", function()
			movecell(0, 1)
		end)
	else
		vis.win:unmap(vis.modes.NORMAL, "<Tab>")
		vis.win:unmap(vis.modes.INSERT, "<Tab>")
		vis.win:unmap(vis.modes.NORMAL, "<S-Tab>")
		vis.win:unmap(vis.modes.INSERT, "<S-Tab>")
		vis.win:unmap(vis.modes.NORMAL, "<C-h>")
		vis.win:unmap(vis.modes.NORMAL, "<C-l>")
		vis.win:unmap(vis.modes.NORMAL, "gh")
		vis.win:unmap(vis.modes.NORMAL, "gj")
		vis.win:unmap(vis.modes.NORMAL, "gk")
		vis.win:unmap(vis.modes.NORMAL, "gl")
	end
	return true
end, "vis table-mode")

return M
