function GeneratePassword(length)
	math.randomseed(os.time())
	local upper = {
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	}
	local have_upper = false
	local lower = {
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	}
	local have_lower = false
	local number = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
	local have_number = false
	local special = {
		"!", "@", "#", "$", "%", "%", "^", "&", "*", "(", ")", "_", "=",
		"-", "+", ",", ".", "?", "<", ">", ";", ":", "~", "/", "{", "}",
		"[", "]", "/",
	}
	local have_special = false
	local pass
	repeat
		local choice = 0
		pass = ""
		for _ = 1, length do
			choice = math.random(4)
			if choice == 1 then
				pass = pass .. upper[math.random(#upper)]
				have_upper = true
			elseif choice == 2 then
				pass = pass .. lower[math.random(#lower)]
				have_lower = true
			elseif choice == 3 then
				pass = pass .. special[math.random(#special)]
				have_special = true
			else
				pass = pass .. number[math.random(#number)]
				have_number = true
			end
		end
	until (have_upper and have_lower and have_number and have_special)
	return pass
end

function InsertPassword()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local uuid = GeneratePassword(13)
	vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
end
