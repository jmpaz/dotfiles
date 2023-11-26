return {
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
}
