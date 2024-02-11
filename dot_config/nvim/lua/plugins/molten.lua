return {
  {
    "benlubas/molten-nvim",
    version = "<2.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      -- molten-nvim keybindings
      local wk = require("which-key")

      -- Setting global variables for molten
      vim.g.molten_output_win_max_height = 20

      -- Key bindings setup
      vim.keymap.set("n", "<localleader>mki", ":MoltenInit<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mkd", ":MoltenDeinit<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mkr", ":MoltenRestart<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mks", ":MoltenInterrupt<CR>", { silent = true })

      vim.keymap.set("n", "<localleader>mcg", ":MoltenGoto<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mcn", ":MoltenNext<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mcp", ":MoltenPrev<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mcd", ":MoltenDelete<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mcr", ":MoltenReevaluateCell<CR>", { silent = true })

      vim.keymap.set("n", "<localleader>mrl", ":MoltenEvaluateLine<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mro", ":MoltenEvaluateOperator<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mra", ":MoltenEvaluateArgument<CR>", { silent = true })

      vim.keymap.set("n", "<localleader>mos", ":MoltenShowOutput<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>moh", ":MoltenHideOutput<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>moe", ":noautocmd MoltenEnterOutput<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>moo", ":MoltenOpenInBrowser<CR>", { silent = true })

      vim.keymap.set("n", "<localleader>mfs", ":MoltenSave<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mfl", ":MoltenLoad<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mfe", ":MoltenExportOutput<CR>", { silent = true })
      vim.keymap.set("n", "<localleader>mfi", ":MoltenImportOutput<CR>", { silent = true })

      vim.keymap.set("n", "<localleader>mi", ":MoltenInfo<CR>", { silent = true })
      vim.keymap.set(
        "v",
        "<localleader>m",
        ":<C-u>MoltenEvaluateVisual<CR>",
        { silent = true, desc = "Evaluate selection (Molten)" }
      )

      -- which-key menu definition
      wk.register({
        m = {
          name = "Molten",
          k = {
            name = "Kernel",
            i = "Initialize Kernel",
            d = "De-initialize Kernel",
            r = "Restart Kernel",
            s = "Interrupt Kernel",
          },
          c = {
            name = "Cells",
            g = "Go to Cell",
            n = "Next Cell",
            p = "Previous Cell",
            d = "Delete Cell",
            r = "Re-evaluate Cell",
          },
          r = {
            name = "Evaluate",
            l = "Evaluate Line",
            o = "Evaluate Operator",
            a = "Evaluate Argument",
          },
          o = {
            name = "Output",
            s = "Show Output Window",
            h = "Hide Output Window",
            e = "Enter Output Window",
            o = "Open Output in Browser",
          },
          f = {
            name = "File",
            s = "Save Cells",
            l = "Load Cells",
            e = "Export to .ipynb",
            i = "Import from .ipynb",
          },
          i = "Info",
        },
      }, { prefix = "<localleader>" })
    end,
  },
}
