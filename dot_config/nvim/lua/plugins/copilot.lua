return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = {
        enabled = true,
        layout = {
          position = "bottom",
          ratio = 0.3,
        },
        keymap = {
          -- open = "<C-o>",
          accept = "<CR>",
          refresh = "gr",
          jump_prev = "=-",
          jump_next = "-=",
        },
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
    init = function()
      vim.keymap.set("n", "<C-p>", ":Copilot panel<CR>", { silent = true })
      vim.keymap.set("i", "<C-p>", "<esc>:Copilot panel<CR>", { silent = true })
    end,
  },
  {
    "nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "copilot",
        group_index = 2,
        priority = 100,
      })
    end,
  },
}
