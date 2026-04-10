{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    vim-dadbod
    vim-dadbod-completion
    vim-dadbod-ui
  ];

  extraConfigLuaPost = ''
    vim.g.omni_sql_default_compl_type = 'syntax'
    vim.g.db_ui_auto_execute_table_helpers = 1
    vim.g.db_ui_execute_on_save = false
    vim.g.db_ui_show_database_icon = true
    vim.g.db_ui_tmp_query_location = vim.fs.joinpath(vim.fn.stdpath('data'), 'dadbod_ui', 'tmp')
    vim.g.db_ui_save_location = vim.fs.joinpath(vim.fn.stdpath('data'), 'dadbod_ui')
    vim.g.db_ui_use_nerd_fonts = true
    vim.g.db_ui_use_nvim_notify = true

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'sql', 'mysql', 'plsql' },
      callback = function(ev)
        vim.bo[ev.buf].completefunc = 'vim_dadbod_completion#omni'
      end,
      desc = 'Enable dadbod completion for SQL buffers',
    })
  '';
}
