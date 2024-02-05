return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        markdownlint = {
          args = {
            "--disable",
            "MD003",
            "--disable",
            "MD010",
            "--disable",
            "MD012",
            "--disable",
            "MD013",
            "--disable",
            "MD022",
            "--disable",
            "MD031",
            "--disable",
            "MD032",
            "--disable",
            "MD034",
            "--disable",
            "MD041",
            "--disable",
            "MD047",
            "--",
          },
        },
      },
    },
  },
}
