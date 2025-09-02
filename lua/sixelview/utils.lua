local M = {}

local function log(msg)
	vim.api.nvim_echo({ { "[sixelview] " .. tostring(msg), "Comment" } }, true, {})
end

---@param str string
local echoraw = function(str)
	vim.fn.chansend(vim.v.stderr, str)
end

---@param path string
---@param args table
---@param lnum number
---@param cnum number
local send_sequence = function(path, args, lnum, cnum)
	-- https://zenn.dev/vim_jp/articles/358848a5144b63#%E7%94%BB%E5%83%8F%E8%A1%A8%E7%A4%BA%E9%96%A2%E6%95%B0%E3%81%AE%E4%BE%8B
	-- save cursor pos
	echoraw("\27[s")
	-- move cursor pos
	echoraw(string.format("\27[%d;%dH", lnum, cnum))
	local cmd = string.format("img2sixel %s %s", table.concat(args, " "), path)
	echoraw(vim.fn.system(cmd))
	-- restore cursor pos
	echoraw("\27[u")
end

local get_image_size = function(img_path)
	local out = vim.fn.system(string.format("identify -format '%%w %%h' %s", img_path))
	local w, h = out:match("(%d+)%s+(%d+)")
	if not w or not h then
		return nil, nil
	end
	return tonumber(w), tonumber(h)
end

---@param img_path string
local display_sixel = function(img_path, constraints)
	constraints = constraints or {}
	local win_position = vim.api.nvim_win_get_position(0)
	local y = win_position[1]
	local x = win_position[2]
	local args = {}

	if constraints then
		local resize = false
		local target_w, target_h
		local w, h = get_image_size(img_path)
		if w and h then
			if constraints.max_width and w > constraints.max_width then
				resize = true
				target_w = constraints.max_width
				target_h = math.floor(h * (constraints.max_width / w))
				w, h = target_w, target_h
			elseif constraints.max_height and h > constraints.max_height then
				resize = true
				target_h = constraints.max_height
				target_w = math.floor(w * (constraints.max_height / h))
				w, h = target_w, target_h
			elseif constraints.min_width and w < constraints.min_width then
				resize = true
				target_w = constraints.min_width
				target_h = math.floor(h * (constraints.min_width / w))
				w, h = target_w, target_h
			elseif constraints.min_height and h < constraints.min_height then
				resize = true
				target_h = constraints.min_height
				target_w = math.floor(w * (constraints.min_height / h))
				w, h = target_w, target_h
			end
		end

		if resize then
			table.insert(args, string.format("--width=%d", w))
			table.insert(args, string.format("--height=%d", h))
			log("Resize args: " .. table.concat(args, " "))
		else
			log("No resize needed, using original image size")
		end
	end
	send_sequence(img_path, args, y + 1, x + 1)
end

---@param delay_ms number
---@param constraints sixelview.ImageConstraints?
M.defer_display_sixel = function(delay_ms, constraints)
	local img_path = vim.fn.expand("%:p")

	local defered_proc = function()
		local cur_path = vim.fn.expand("%:p")
		if img_path == cur_path then
			vim.defer_fn(function()
				display_sixel(img_path, constraints)
			end, delay_ms)
		end
	end

	vim.defer_fn(defered_proc, delay_ms)
end

---@param img_path string
---@param pattern string[]
---@return boolean
M.is_image_buffer = function(img_path, pattern)
	for _, pat in pairs(pattern) do
		local img_extension = string.lower(string.sub(img_path, #img_path - (#pat - 2)))
		local pat_extension = string.lower(string.sub(pat, 2))
		if img_extension == pat_extension then
			return true
		end
	end
	return false
end

return M
