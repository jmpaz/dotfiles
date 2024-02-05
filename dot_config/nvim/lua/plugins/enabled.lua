return {
  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },
  {
    "xvzc/chezmoi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("chezmoi").setup({
        edit = {
          watch = true,
          force = false, -- force apply
        },
      })
    end,
  },
  {
    "gen740/SmoothCursor.nvim",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("smoothcursor").setup({
        speed = 20,
        intervals = 20,
      })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup()
    end,
  },
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "mistral",
      display_mode = "float", -- Can be "float" or "split".
      show_prompt = false,
      show_model = true,
      no_auto_close = false,
      init = function(options)
        pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
      end,
      command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
      list_models = "<omitted lua function>", -- Retrieves a list of model names
      debug = false,
    },
  },
}
