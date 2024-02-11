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

      -- bindings
      vim.keymap.set("n", "<localleader>rc", runner.run_cell, { silent = true })
      vim.keymap.set("n", "<localleader>ra", runner.run_above, { silent = true })
      vim.keymap.set("n", "<localleader>rA", runner.run_all, { silent = true })
      vim.keymap.set("n", "<localleader>rl", runner.run_line, { silent = true })
      vim.keymap.set("v", "<localleader>r", runner.run_range, { silent = true, desc = "Evaluate selection (Quarto)" })

      -- which-key
      local wk = require("which-key")
      wk.register({
        r = {
          name = "Run (Quarto)",
          c = "Run Cell",
          a = "Run Cell + Above",
          A = "Run All Cells",
          l = "Run Line",
        },
      }, { prefix = "<localleader>" })
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
