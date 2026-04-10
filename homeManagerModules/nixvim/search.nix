{ pkgs, ... }:
let
  upstream = pkgs.vimPlugins.grug-far-nvim;
  grugFarPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = upstream.pname;
    version = upstream.version;
    src = upstream.src;
  };
in
{
  extraPlugins = [ grugFarPlugin ];

  extraConfigLuaPost = ''
    local grug_far = require('grug-far')

    grug_far.setup({})

    local files_grug_far_replace = function()
      local entry = MiniFiles.get_fs_entry()
      if entry == nil or entry.path == nil then
        return
      end

      local prefills = { paths = vim.fs.dirname(entry.path) }
      if not grug_far.has_instance('explorer') then
        grug_far.open({
          instanceName = 'explorer',
          prefills = prefills,
          staticTitle = 'Find and Replace from Explorer',
        })
        return
      end

      local instance = grug_far.get_instance('explorer')
      instance:open()
      instance:update_input_values(prefills, false)
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        vim.keymap.set('n', 'gs', files_grug_far_replace, {
          buffer = args.data.buf_id,
          desc = 'Search current directory',
        })
      end,
      desc = 'Search current MiniFiles directory with grug-far',
    })
  '';
}
