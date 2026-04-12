local enabled = vim.env.OBSIDIAN_ENABLE
if enabled == nil or enabled ~= "1" then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      pcall(vim.api.nvim_del_user_command, "Obsidian")
    end,
    desc = "Remove Obsidian command when integration is disabled",
  })
  return
end

local ok_obsidian, obsidian = pcall(require, "obsidian")
if not ok_obsidian then
  return
end

local home = vim.env.HOME or vim.fn.expand("~")
local vaults_json = vim.env.OBSIDIAN_VAULTS_JSON
if vaults_json == nil or vaults_json == "" then
  vaults_json = '[{"name":"personal","path":"Notes","strict":false}]'
end

local vaults = vim.json.decode(vaults_json)
local daily_tags_json = vim.env.OBSIDIAN_DAILY_NOTES_TAGS_JSON
if daily_tags_json == nil or daily_tags_json == "" then
  daily_tags_json = '["daily-notes"]'
end

for _, vault in ipairs(vaults) do
  local path = vault.path
  if type(path) == "string" and not path:match("^/") then
    path = vim.fs.joinpath(home, path)
  end
  vault.path = path
  vim.fn.mkdir(path, "p")
end

local opts = {
  legacy_commands = false,
  statusline = { enabled = false },
  completion = {
    nvim_cmp = false,
    blink = false,
  },
  picker = {
    name = "mini.pick",
  },
  workspaces = vaults,
  daily_notes = {
    enabled = (vim.env.OBSIDIAN_DAILY_NOTES_ENABLED or "1") == "1",
    folder = nil,
    workdays_only = (vim.env.OBSIDIAN_DAILY_NOTES_WORKDAYS_ONLY or "1") == "1",
    default_tags = vim.json.decode(daily_tags_json),
  },
  templates = {
    enabled = (vim.env.OBSIDIAN_TEMPLATES_ENABLED or "1") == "1",
    folder = nil,
  },
  attachments = {
    folder = vim.env.OBSIDIAN_ATTACHMENTS_FOLDER or "attachments",
  },
}

local daily_folder = vim.env.OBSIDIAN_DAILY_NOTES_FOLDER
if daily_folder ~= nil and daily_folder ~= "" then
  opts.daily_notes.folder = daily_folder
end

local templates_folder = vim.env.OBSIDIAN_TEMPLATES_FOLDER
if templates_folder ~= nil and templates_folder ~= "" then
  opts.templates.folder = templates_folder
end

obsidian.setup(opts)

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

map("<leader>on", "<cmd>Obsidian new<cr>", "Obsidian new note")
map("<leader>oo", "<cmd>Obsidian open<cr>", "Open current note in Obsidian")
map("<leader>op", "<cmd>Obsidian paste_img<cr>", "Paste image into note")
map("<leader>oq", "<cmd>Obsidian quick_switch<cr>", "Quick switch notes")
map("<leader>os", "<cmd>Obsidian search<cr>", "Search notes")
map("<leader>ot", "<cmd>Obsidian today<cr>", "Open todays daily note")
map("<leader>oT", "<cmd>Obsidian template<cr>", "Insert template")
map("<leader>ow", "<cmd>Obsidian workspace<cr>", "Switch Obsidian workspace")
