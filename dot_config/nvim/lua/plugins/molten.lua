return {
  {
    "benlubas/molten-nvim",
    version = "<2.0.0",
    -- dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20

      -- Keymaps
      vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { silent = true })
      -- vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { silent = true })
      vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true })

      local wk = require("which-key")
      wk.register({
        m = { name = "Molten", i = { ":MoltenInit<CR>", "Initialize the Jupyter kernel" } },
        r = {
          name = "Run (Jupyter)",
          e = { ":MoltenEvaluateOperator<CR>", "Evaluate operator selection" },
          l = { ":MoltenEvaluateLine<CR>", "Evaluate line" },
          r = { ":MoltenReevaluateCell<CR>", "Re-evaluate cell" },
        },
      }, { prefix = "<localleader>" })

      wk.register({
        r = { ":<C-u>MoltenEvaluateVisual<CR>gv", "Evaluate visual selection" },
      }, { prefix = "<localleader>", mode = "v" }) -- Specify the mode as visual
    end,
  },
