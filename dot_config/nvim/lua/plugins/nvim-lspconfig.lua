return {
  "neovim/nvim-lspconfig",
  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = require("lazyvim.config").icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = require("lazyvim.config").icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = require("lazyvim.config").icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = require("lazyvim.config").icons.diagnostics.Info,
        },
      },
    },
    inlay_hints = {
      enabled = true,
    },
    capabilities = {},
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    -- LSP Server Settings
    ---@type lspconfig.options
    servers = {
      lua_ls = {
        ---@type LazyKeysSpec[]
        -- keys = {},
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      pyright = {
        settings = {
          pyright = {
            disableOrganizeImports = true, -- Using Ruff
          },
          python = {
            analysis = {
              ignore = { "*" }, -- Using Ruff
              typeCheckingMode = "off", -- Using mypy
            },
          },
        },
      },
    },
    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    setup = {},
  },
}
