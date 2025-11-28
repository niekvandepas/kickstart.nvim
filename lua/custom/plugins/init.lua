-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
local group = vim.api.nvim_create_augroup('autosave', {})

vim.api.nvim_create_autocmd('User', {
    pattern = 'AutoSaveWritePost',
    group = group,
    callback = function(opts)
        if opts.data.saved_buffer ~= nil then
            local filename = vim.api.nvim_buf_get_name(opts.data.saved_buffer)
            vim.notify('AutoSave: saved ' .. filename .. ' at ' .. vim.fn.strftime('%H:%M:%S'), vim.log.levels.INFO)
        end
    end,
})

return {
  -- Disabled because it kept throwing errors
  -- {
  --   "folke/todo-comments.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     highlight = {
  --       before = "bg",
  --       pattern = [[.*<(KEYWORDS)\s*]],
  --       after = "bg",
  --     },
  --   },
  -- },
  {
    "nvim-pack/nvim-spectre",
    keys = {
      {'<F4>', "<cmd>SpectreWithCWD<cr>",mode={'n'} },
    },
    config = function()
      require('spectre').setup({ is_block_ui_break = true })
    end,
  },
  {
    "github/copilot.vim"
  },
  {
    "okuuva/auto-save.nvim",
    version = '^1.0.0', -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      -- your config goes here
      -- or just leave it empty :)
    },
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons'
  },
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    config = function()
	require("markview").setup({
	    preview = { enable = false }
	});

	vim.keymap.set('n', '<leader>ms', ':Markview splitToggle<CR>', { desc = 'Toggle Markview split' })
    end
  },
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
      'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
    },
    config = function()
      -- list of formatters & listers for mason to install
      require('mason-null-ls').setup {
        ensure_installed = {
          'ruff',
          'prettier',
          'shfmt',
        },
        automatic_installation = true,
      }

      local null_ls = require 'null-ls'
      local sources = {
        require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
        require 'none-ls.formatting.ruff_format',
        null_ls.builtins.formatting.prettier.with { filetypes = { 'json', 'yaml', 'markdown' } },
        null_ls.builtins.formatting.shfmt.with { args = { '-i', '4' } },
      }

      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
      null_ls.setup {
        -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
        sources = sources,
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format { async = false }
              end,
            })
          end
        end
      }

    end
  }

}
