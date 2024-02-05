return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        markdownlint = {
          args = {
            "--disable",
            "MD013",
            "--disable",
            "MD010",
            "--disable",
            "MD012",
            "--disable",
            "MD041",
            "--",
          },
        },
      },
    },
  },
}
