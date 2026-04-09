{ ... }:
{
  extraFiles = {
    "snippets/global.json".text = ''
      {
        "Current datetime": {
          "prefix": "cdtm",
          "body": "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND",
          "description": "Insert current datetime (YYYY-mm-dd HH:MM:SS)"
        },
        "Current date": {
          "prefix": "cdate",
          "body": "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE",
          "description": "Insert current date (YYYY-mm-dd)"
        },
        "Current time": {
          "prefix": "ctime",
          "body": "$CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND",
          "description": "Insert current time (HH:MM:SS)"
        }
      }
    '';
    "after/snippets/lua.json".text = ''
      {
        "local": { "prefix": "l", "body": "local $1 = $0" },
        "Remove prefixes": { "prefix": ["lfu", "ll", "lpca"] }
      }
    '';
    "after/ftplugin/gitcommit.lua".text = ''
      vim.opt_local.spell = true
      vim.opt_local.wrap = true
    '';
    "after/ftplugin/markdown.lua".text = ''
      vim.opt_local.spell = true
      vim.opt_local.wrap = true
      vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')
      pcall(vim.keymap.del, 'n', 'gO', { buffer = 0 })

      vim.b.minisurround_config = {
        custom_surroundings = {
          L = {
            input = { '%[().-()%]%(.-%)' },
            output = function()
              local link = require('mini.surround').user_input('Link: ')
              return { left = '[', right = '](' .. link .. ')' }
            end,
          },
        },
      }
    '';
  };
}
