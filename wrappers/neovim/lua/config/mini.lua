local setup = function(module, opts)
	require("mini." .. module).setup(opts or {})
end

setup("ai", {
	custom_textobjects = {
		A = require("mini.ai").gen_spec.treesitter({
			a = "@assignment.outer",
			i = "@assignment.inner",
		}),
		B = require("mini.extra").gen_ai_spec.buffer(),
		C = require("mini.ai").gen_spec.treesitter({
			a = "@class.outer",
			i = "@class.inner",
		}),
		F = require("mini.ai").gen_spec.treesitter({
			a = "@function.outer",
			i = "@function.inner",
		}),
		I = require("mini.ai").gen_spec.treesitter({
			a = "@conditional.outer",
			i = "@conditional.inner",
		}),
		L = require("mini.ai").gen_spec.treesitter({
			a = "@loop.outer",
			i = "@loop.inner",
		}),
		P = require("mini.ai").gen_spec.treesitter({
			a = "@parameter.outer",
			i = "@parameter.inner",
		}),
	},
	n_lines = 100,
	search_method = "cover_or_next",
})

setup("align")
setup("basics", {
	options = {
		basic = false,
	},
	mappings = {
		move_with_alt = true,
		windows = true,
	},
})
setup("bracketed")
setup("bufremove")
setup("cmdline")
setup("comment")
setup("completion", {
	delay = {
		completion = 100,
		info = 100,
		signature = 50,
	},
	lsp_completion = {
		auto_setup = false,
		process_items = function(items, base)
			return MiniCompletion.default_process_items(items, base, {
				kind_priority = {
					Text = -1,
					Snippet = 99,
				},
			})
		end,
		source_func = "omnifunc",
	},
	window = {
		info = {
			border = nil,
			height = 25,
			width = 80,
		},
		signature = {
			border = nil,
			height = 25,
			width = 80,
		},
	},
})
setup("cursorword")
setup("diff")
setup("extra")
setup("files", {
	options = {
		use_as_default_explorer = false,
	},
	windows = {
		preview = true,
	},
})
setup("git")
setup("hipatterns", {
	highlighters = {
		fixme = require("mini.extra").gen_highlighter.words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
		hack = require("mini.extra").gen_highlighter.words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
		hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
		note = require("mini.extra").gen_highlighter.words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
		todo = require("mini.extra").gen_highlighter.words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
	},
})
setup("icons", {
	use_file_extension = function(ext, _)
		local ext3_blocklist = { scm = true, txt = true, yml = true }
		local ext4_blocklist = { json = true, yaml = true }

		return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
	end,
})
MiniIcons.mock_nvim_web_devicons()
setup("indentscope", { symbol = "│" })
setup("jump")
setup("jump2d")
setup("keymap")

local map_integrations = (function()
	local refresh = function()
		if _G.MiniMap ~= nil then
			MiniMap.refresh(nil, { lines = false, scrollbar = false })
		end
	end

	vim.api.nvim_create_autocmd("OptionSet", {
		group = vim.api.nvim_create_augroup("ConfigMiniMapBuiltinSearch", { clear = true }),
		pattern = "hlsearch",
		callback = refresh,
		desc = "On 'hlsearch' update",
	})

	local builtin_search = function()
		if vim.v.hlsearch == 0 or not vim.o.hlsearch then
			return {}
		end

		local win_view = vim.fn.winsaveview()
		local search_count = vim.fn.searchcount({ recompute = true, maxcount = 0 })
		local search_pattern = vim.fn.getreg("/")
		local line_hl = {}

		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		for _ = 1, (search_count.total or 0) do
			vim.fn.search(search_pattern)
			table.insert(line_hl, { line = vim.fn.line("."), hl_group = "Search" })
		end

		vim.fn.winrestview(win_view)

		return line_hl
	end

	return {
		builtin_search,
		require("mini.map").gen_integration.diff(),
		require("mini.map").gen_integration.diagnostic(),
	}
end)()

setup("map", {
	integrations = map_integrations,
	symbols = {
		encode = require("mini.map").gen_encode_symbols.dot("4x2"),
	},
})
setup("misc")
setup("move")
setup("notify")
setup("operators")
setup("pairs", {
	modes = {
		command = true,
	},
})
setup("pick")
setup("sessions")
setup("snippets", {
	snippets = {
		(function()
			local mini_snippets = require("mini.snippets")
			local global_path = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets", "global.json")

			return mini_snippets.gen_loader.from_file(global_path, { silent = true })
		end)(),
		(function()
			local mini_snippets = require("mini.snippets")
			local config_root = vim.fn.stdpath("config")
			local roots = {
				vim.fs.joinpath(config_root, "snippets"),
				vim.fs.joinpath(config_root, "after", "snippets"),
			}
			local lang_aliases = {
				tex = { "latex" },
				plaintex = { "latex" },
				markdown_inline = { "markdown" },
			}

			local read_file = function(path)
				return mini_snippets.read_file(path, { cache = true, silent = true }) or {}
			end

			local direct_paths = function(lang)
				local names = lang_aliases[lang] or { lang }
				local paths = {}

				for _, root in ipairs(roots) do
					for _, name in ipairs(names) do
						table.insert(paths, vim.fs.joinpath(root, name .. ".json"))
						table.insert(paths, vim.fs.joinpath(root, name .. ".lua"))
					end
				end

				return paths
			end

			return function(context)
				local lang = (context or {}).lang
				if type(lang) ~= "string" or lang == "" then
					return {}
				end

				local res = {}
				for _, path in ipairs(direct_paths(lang)) do
					table.insert(res, read_file(path))
				end

				return res
			end
		end)(),
	},
})
setup("splitjoin")
setup("starter", {
	autoopen = true,
	evaluate_single = true,
	footer = "",
	header = [[
██████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
██╔══██╗██╔══██╗██║   ██║██║████╗ ████║
██████╔╝██████╔╝██║   ██║██║██╔████╔██║
██╔══██╗██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║
██████╔╝██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
	items = (function()
		local local_session_name = MiniSessions.config.file or "Session.vim"
		local local_session_path = vim.fs.joinpath(vim.fn.getcwd(), local_session_name)
		local has_local_session = vim.fn.filereadable(local_session_path) == 1

		return {
			{ action = "Pick files", name = "f  󰱼  Find File", section = "" },
			{ action = "enew | startinsert", name = "n    New File", section = "" },
			{ action = "Pick grep_live", name = "g    Find Text", section = "" },
			{ action = "Pick oldfiles", name = "r    Recent Files", section = "" },
			{
				action = has_local_session and function()
					MiniSessions.read(local_session_name)
				end or "",
				name = "s    Restore Local Session",
				section = "",
			},
			{
				action = function()
					MiniSessions.select("read")
				end,
				name = "m  󰆓  Session Picker",
				section = "",
			},
			{ action = "qall", name = "q    Quit", section = "" },
		}
	end)(),
	content_hooks = {
		require("mini.starter").gen_hook.aligning("center", "center"),
	},
})
setup("statusline", { use_icons = true })
setup("surround")
setup("tabline")
setup("trailspace")
setup("visits")

MiniIcons.tweak_lsp_kind()

MiniMisc.setup_auto_root()
MiniMisc.setup_restore_cursor()
MiniMisc.setup_termbg_sync()

local uv = vim.uv or vim.loop
local minifiles_git_ns = vim.api.nvim_create_namespace("MiniFilesGitSigns")
local minifiles_git_signs = {
	added = { text = "+", hl = "MiniFilesGitAdded" },
	modified = { text = "~", hl = "MiniFilesGitModified" },
	deleted = { text = "-", hl = "MiniFilesGitDeleted" },
	renamed = { text = ">", hl = "MiniFilesGitRenamed" },
	untracked = { text = "?", hl = "MiniFilesGitUntracked" },
	conflicted = { text = "!", hl = "MiniFilesGitConflict" },
}
local minifiles_git_priority = {
	conflicted = 60,
	deleted = 50,
	modified = 40,
	renamed = 30,
	added = 20,
	untracked = 10,
}

vim.api.nvim_set_hl(0, "MiniFilesGitAdded", { default = true, link = "DiagnosticOk" })
vim.api.nvim_set_hl(0, "MiniFilesGitModified", { default = true, link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "MiniFilesGitDeleted", { default = true, link = "DiagnosticError" })
vim.api.nvim_set_hl(0, "MiniFilesGitRenamed", { default = true, link = "DiagnosticInfo" })
vim.api.nvim_set_hl(0, "MiniFilesGitUntracked", { default = true, link = "DiagnosticHint" })
vim.api.nvim_set_hl(0, "MiniFilesGitConflict", { default = true, link = "DiagnosticError" })

local minifiles_buf_path = function(buf_id)
	local name = vim.api.nvim_buf_get_name(buf_id)
	return name:match("^minifiles://%d+/(.*)$")
end

local minifiles_git_root = function(path)
	local dir = path
	local stat = uv.fs_stat(dir)
	if not (stat and stat.type == "directory") then
		dir = vim.fs.dirname(path)
	end

	if type(dir) ~= "string" or dir == "" then
		return nil
	end

	local result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if result.code ~= 0 then
		return nil
	end

	return vim.trim(result.stdout)
end

local minifiles_git_kind = function(xy)
	if xy == "??" then
		return "untracked"
	end

	if xy:find("U", 1, true) or xy == "AA" or xy == "DD" then
		return "conflicted"
	end

	if xy:find("D", 1, true) then
		return "deleted"
	end

	if xy:find("R", 1, true) or xy:find("C", 1, true) then
		return "renamed"
	end

	if xy:find("M", 1, true) or xy:find("T", 1, true) then
		return "modified"
	end

	if xy:find("A", 1, true) then
		return "added"
	end

	return nil
end

local minifiles_git_stronger = function(current, incoming)
	if current == nil then
		return incoming
	end

	if incoming == nil then
		return current
	end

	if (minifiles_git_priority[incoming] or 0) > (minifiles_git_priority[current] or 0) then
		return incoming
	end

	return current
end

local minifiles_git_collect = function(dir_path)
	local root = minifiles_git_root(dir_path)
	if root == nil then
		return {}
	end

	local rel = "."
	if dir_path ~= root and vim.startswith(dir_path, root .. "/") then
		rel = dir_path:sub(#root + 2)
	end

	local result = vim.system({
		"git",
		"-C",
		root,
		"status",
		"--porcelain=v1",
		"-z",
		"--ignored=no",
		"--untracked-files=all",
		"--",
		rel,
	}, { text = true }):wait()

	if result.code ~= 0 or type(result.stdout) ~= "string" or result.stdout == "" then
		return {}
	end

	local statuses = {}
	local index = 1
	local output = result.stdout

	while index <= #output do
		local xy = output:sub(index, index + 1)
		index = index + 3

		local path_end = output:find("\0", index, true)
		if path_end == nil then
			break
		end

		local rel_path = output:sub(index, path_end - 1)
		index = path_end + 1

		local kind = minifiles_git_kind(xy)
		if kind ~= nil and rel_path ~= "" then
			local full_path = root .. "/" .. rel_path
			statuses[full_path] = minifiles_git_stronger(statuses[full_path], kind)
		end

		if xy:find("R", 1, true) or xy:find("C", 1, true) then
			local old_end = output:find("\0", index, true)
			if old_end == nil then
				break
			end
			index = old_end + 1
		end
	end

	return statuses
end

local minifiles_git_status_for_entry = function(entry, statuses)
	local status = statuses[entry.path]
	if status ~= nil or entry.fs_type ~= "directory" then
		return status
	end

	local prefix = entry.path .. "/"
	for changed_path, changed_status in pairs(statuses) do
		if vim.startswith(changed_path, prefix) then
			status = minifiles_git_stronger(status, changed_status)
		end
	end

	return status
end

local minifiles_render_git_signs = function(buf_id)
	vim.api.nvim_buf_clear_namespace(buf_id, minifiles_git_ns, 0, -1)

	local path = minifiles_buf_path(buf_id)
	local stat = type(path) == "string" and uv.fs_stat(path) or nil
	if not (stat and stat.type == "directory") then
		return
	end

	local statuses = minifiles_git_collect(path)
	if vim.tbl_isempty(statuses) then
		return
	end

	local line_count = vim.api.nvim_buf_line_count(buf_id)
	for line = 1, line_count do
		local entry = MiniFiles.get_fs_entry(buf_id, line)
		if entry ~= nil then
			local kind = minifiles_git_status_for_entry(entry, statuses)
			local sign = kind and minifiles_git_signs[kind] or nil

			if sign ~= nil then
				vim.api.nvim_buf_set_extmark(buf_id, minifiles_git_ns, line - 1, 0, {
					sign_text = sign.text,
					sign_hl_group = sign.hl,
					priority = 200,
				})
			end
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesExplorerOpen",
	callback = function()
		MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
	end,
	desc = "Add MiniFiles bookmarks",
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesWindowOpen",
	callback = function(args)
		if args.data.win_id ~= nil and vim.api.nvim_win_is_valid(args.data.win_id) then
			vim.wo[args.data.win_id].signcolumn = "yes:1"
		end
	end,
	desc = "Show MiniFiles git sign column",
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferUpdate",
	callback = function(args)
		minifiles_render_git_signs(args.data.buf_id)
	end,
	desc = "Render MiniFiles git indicators",
})

MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })

for _, key in ipairs({ "n", "N", "*", "#" }) do
	local rhs = key .. "zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
	vim.keymap.set("n", key, rhs)
end

local mini_statusline = require("mini.statusline")
local default_laststatus = vim.o.laststatus
local codecompanion_spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local codecompanion_requests = 0
local codecompanion_spinner_frame = 1
local codecompanion_spinner_timer

local redraw_statusline = function()
	vim.cmd("redrawstatus")
end

local stop_codecompanion_spinner = function()
	if codecompanion_spinner_timer == nil then
		return
	end

	codecompanion_spinner_timer:stop()
	codecompanion_spinner_timer:close()
	codecompanion_spinner_timer = nil
	codecompanion_spinner_frame = 1
end

local start_codecompanion_spinner = function()
	if codecompanion_spinner_timer ~= nil then
		return
	end

	codecompanion_spinner_timer = assert(uv.new_timer())
	codecompanion_spinner_timer:start(
		0,
		120,
		vim.schedule_wrap(function()
			codecompanion_spinner_frame = (codecompanion_spinner_frame % #codecompanion_spinner_frames) + 1
			redraw_statusline()
		end)
	)
end

local refresh_laststatus = function()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local only_starter = #wins > 0

	for _, win in ipairs(wins) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype ~= "ministarter" then
			only_starter = false
			break
		end
	end

	vim.o.laststatus = only_starter and 0 or default_laststatus
end

local schedule_refresh_laststatus = vim.schedule_wrap(refresh_laststatus)

local compact_fileinfo = function()
	local filetype = vim.bo.filetype
	if vim.bo.buftype ~= "" or filetype == "" then
		return mini_statusline.section_fileinfo({ trunc_width = 140 })
	end

	local icon = ""
	if _G.MiniIcons ~= nil then
		local ok, glyph = pcall(MiniIcons.get, "filetype", filetype)
		if ok and type(glyph) == "string" and glyph ~= "" then
			icon = glyph .. " "
		end
	end

	local parts = { icon .. filetype }
	local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
	if encoding ~= "utf-8" then
		table.insert(parts, encoding)
	end
	if vim.bo.fileformat ~= "unix" then
		table.insert(parts, vim.bo.fileformat)
	end

	return table.concat(parts, " ")
end

local diagnostics_summary = function()
	if vim.bo.buftype ~= "" then
		return ""
	end

	local severities = vim.diagnostic.severity
	local counts = {
		error = #vim.diagnostic.get(0, { severity = severities.ERROR }),
		warn = #vim.diagnostic.get(0, { severity = severities.WARN }),
		info = #vim.diagnostic.get(0, { severity = severities.INFO }),
		hint = #vim.diagnostic.get(0, { severity = severities.HINT }),
	}
	local parts = {}

	if counts.error > 0 then
		table.insert(parts, " " .. counts.error)
	end
	if counts.warn > 0 then
		table.insert(parts, " " .. counts.warn)
	end
	if counts.info > 0 then
		table.insert(parts, " " .. counts.info)
	end
	if counts.hint > 0 then
		table.insert(parts, "󰌵 " .. counts.hint)
	end

	return table.concat(parts, " ")
end

local overseer_summary = function()
	local ok_overseer, overseer = pcall(require, "overseer")
	if not ok_overseer then
		return ""
	end

	local ok_constants, constants = pcall(require, "overseer.constants")
	if not ok_constants then
		return ""
	end

	local tasks = overseer.list_tasks({ unique = true, include_ephemeral = false })
	if #tasks == 0 then
		return ""
	end

	local status = constants.STATUS
	local counts = {
		[status.RUNNING] = 0,
		[status.FAILURE] = 0,
		[status.CANCELED] = 0,
	}

	for _, task in ipairs(tasks) do
		if counts[task.status] ~= nil then
			counts[task.status] = counts[task.status] + 1
		end
	end

	local parts = {}
	if counts[status.RUNNING] > 0 then
		table.insert(parts, "󰑮 " .. counts[status.RUNNING])
	end
	if counts[status.FAILURE] > 0 then
		table.insert(parts, "󰅚 " .. counts[status.FAILURE])
	end
	if counts[status.CANCELED] > 0 then
		table.insert(parts, " " .. counts[status.CANCELED])
	end

	return table.concat(parts, " ")
end

local ai_summary = function()
	local parts = {}
	if codecompanion_requests > 0 then
		table.insert(parts, "󰚩 " .. codecompanion_spinner_frames[codecompanion_spinner_frame])
	end

	local ok_status, status = pcall(function()
		return require("sidekick.status").get()
	end)
	if ok_status and type(status) == "table" and next(status) ~= nil then
		table.insert(parts, status.busy and "…" or "")
	end

	local ok_cli, cli = pcall(function()
		return require("sidekick.status").cli()
	end)
	if ok_cli and type(cli) == "table" and #cli > 0 then
		table.insert(parts, " " .. (#cli > 1 and tostring(#cli) or ""))
	end

	return table.concat(parts, " ")
end

mini_statusline.config.content.active = function()
	local mode, mode_hl = mini_statusline.section_mode({ trunc_width = 0 })
	local git = mini_statusline.section_git({ trunc_width = 0 })
	local diff = mini_statusline.section_diff({ trunc_width = 0 })
	local diagnostics = diagnostics_summary()
	local lsp = mini_statusline.section_lsp({ trunc_width = 0 })
	local filename = mini_statusline.section_filename({ trunc_width = 0 })
	local fileinfo = compact_fileinfo()
	local ai = ai_summary()
	local tasks = overseer_summary()
	local location = mini_statusline.section_location({ trunc_width = 0 })
	local search = mini_statusline.section_searchcount({ trunc_width = 0 })

	return mini_statusline.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
		{ hl = "MiniStatuslineFilename", strings = { filename } },
		"%=",
		{ hl = "MiniStatuslineFileinfo", strings = { fileinfo, ai, tasks } },
		{ hl = mode_hl, strings = { search, location } },
	})
end

local statusline_augroup = vim.api.nvim_create_augroup("ConfigStarterStatusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "DiagnosticChanged", "FileType", "TabEnter", "WinEnter" }, {
	group = statusline_augroup,
	callback = refresh_laststatus,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = statusline_augroup,
	callback = schedule_refresh_laststatus,
})

vim.api.nvim_create_autocmd("User", {
	group = statusline_augroup,
	pattern = "MiniStarterOpened",
	callback = schedule_refresh_laststatus,
})

vim.api.nvim_create_autocmd("User", {
	group = statusline_augroup,
	pattern = "CodeCompanionRequest*",
	callback = function(args)
		if args.match == "CodeCompanionRequestStarted" then
			codecompanion_requests = codecompanion_requests + 1
			start_codecompanion_spinner()
		elseif args.match == "CodeCompanionRequestFinished" then
			codecompanion_requests = math.max(0, codecompanion_requests - 1)
			if codecompanion_requests == 0 then
				stop_codecompanion_spinner()
			end
		end

		redraw_statusline()
	end,
})

vim.api.nvim_create_autocmd("User", {
	group = statusline_augroup,
	pattern = "OverseerList*",
	callback = redraw_statusline,
})

vim.api.nvim_create_autocmd("WinClosed", {
	group = statusline_augroup,
	callback = schedule_refresh_laststatus,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = statusline_augroup,
	callback = stop_codecompanion_spinner,
})

schedule_refresh_laststatus()

local miniclue = require("mini.clue")

miniclue.setup({
	clues = {
		{ mode = "n", keys = "<Leader>a", desc = "+AI" },
		{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
		{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
		{ mode = "n", keys = "<Leader>e", desc = "+Explore/Edit" },
		{ mode = "n", keys = "<Leader>f", desc = "+Find" },
		{ mode = "n", keys = "<Leader>g", desc = "+Git" },
		{ mode = "n", keys = "<Leader>k", desc = "+Kube" },
		{ mode = "n", keys = "<Leader>l", desc = "+Language" },
		{ mode = "n", keys = "<Leader>m", desc = "+Map" },
		{ mode = "n", keys = "<Leader>n", desc = "+Test" },
		{ mode = "n", keys = "<Leader>o", desc = "+Ops" },
		{ mode = "n", keys = "<Leader>q", desc = "+Quit" },
		{ mode = "n", keys = "<Leader>r", desc = "+Request" },
		{ mode = "n", keys = "<Leader>s", desc = "+Session" },
		{ mode = "n", keys = "<Leader>t", desc = "+Terminal" },
		{ mode = "n", keys = "<Leader>v", desc = "+Visits" },
		{ mode = "x", keys = "<Leader>a", desc = "+AI" },
		{ mode = "x", keys = "<Leader>d", desc = "+Debug" },
		{ mode = "x", keys = "<Leader>f", desc = "+Find" },
		{ mode = "x", keys = "<Leader>g", desc = "+Git" },
		{ mode = "x", keys = "<Leader>l", desc = "+Language" },
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.windows({ submode_resize = true }),
		miniclue.gen_clues.z(),
	},
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = "n", keys = "\\" },
		{ mode = { "n", "x" }, keys = "[" },
		{ mode = { "n", "x" }, keys = "]" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = { "n", "x" }, keys = "s" },
		{ mode = { "n", "x" }, keys = "z" },
	},
})
