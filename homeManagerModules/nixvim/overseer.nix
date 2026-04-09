{ lib, pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [ overseer-nvim ];

  extraConfigLuaPost = lib.mkAfter ''
    local overseer = require('overseer')

    overseer.setup({
      task_list = {
        direction = 'right',
        min_width = { 42, 0.18 },
        max_width = { 84, 0.4 },
        min_height = 8,
        max_height = { 20, 0.2 },
      },
    })

    vim.api.nvim_create_user_command('OverseerRestartLast', function()
      local tasks = overseer.list_tasks({ unique = false, include_ephemeral = false })
      local task = tasks[1]

      if task == nil then
        vim.notify('No Overseer task to restart', vim.log.levels.INFO)
        return
      end

      overseer.run_action(task, task.status == 'PENDING' and 'start' or 'restart')
    end, { desc = 'Restart the most recent Overseer task' })
  '';
}
