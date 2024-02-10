return {
  {
    "quarto-dev/quarto-nvim",
    opts = {
      lspFeatures = {
        languages = { "python", "bash", "html", "lua" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
        never_run = { "yaml" },
      },
    },
    init = function()
      local runner = require("quarto.runner")
      vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
      vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
      vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
      vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
      vim.keymap.set("v", "<localleader>rr", runner.run_range, { desc = "run visual range", silent = true })
    end,
  },
  {
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
  },
}
