local ok_kulala, kulala = pcall(require, "kulala")
if not ok_kulala then
  return
end

kulala.setup({
  global_keymaps = false,
  global_keymaps_prefix = "<Leader>r",
  kulala_keymaps_prefix = "",
})
