local M = {
  -- cURL path
  -- if you have curl installed in a non-standard path,
  -- you can specify it here
  curl_path = "curl",
  -- additional cURL options
  -- see: https://curl.se/docs/manpage.html
  additional_curl_options = {},
  -- gRPCurl path, get from https://github.com/fullstorydev/grpcurl.git
  grpcurl_path = "grpcurl",
  -- websocat path, get from https://github.com/vi/websocat.git
  websocat_path = "websocat",
  -- openssl path
  openssl_path = "openssl",

  -- set scope for environment and request variables
  -- possible values: b = buffer, g = global
  environment_scope = "b",
  -- dev, test, prod, can be anything
  -- see: https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0#environment-files
  default_env = "dev",
  -- enable reading vscode rest client environment variables
  vscode_rest_client_environmentvars = false,

  -- default timeout for the request, set to nil to disable
  request_timeout = nil,
  -- continue running requests when a request failure is encountered
  halt_on_error = true,

  -- certificates
  certificates = {},
  -- Specify how to escape query parameters
  -- possible values: always, skipencoded = keep %xx as is
  urlencode = "always",

  -- default formatters/pathresolver for different content types
  contenttypes = {
    ["application/json"] = {
      ft = "json",
      formatter = vim.fn.executable("jq") == 1 and { "jq", "." },
      pathresolver = function(...)
        return require("kulala.parser.jsonpath").parse(...)
      end,
    },
    ["application/graphql"] = {
      ft = "graphql",
      formatter = vim.fn.executable("prettier") == 1
        and { "prettier", "--stdin-filepath", "graphql", "--parser", "graphql" },
      pathresolver = nil,
    },
    ["application/xml"] = {
      ft = "xml",
      formatter = vim.fn.executable("xmllint") == 1 and { "xmllint", "--format", "-" },
      pathresolver = vim.fn.executable("xmllint") == 1 and { "xmllint", "--xpath", "{{path}}", "-" },
    },
    ["text/html"] = {
      ft = "html",
      formatter = vim.fn.executable("xmllint") == 1 and { "xmllint", "--format", "--html", "-" },
      pathresolver = nil,
    },
  },

  scripts = {
    -- Resolves "NODE_PATH" environment variable for node scripts. Defaults to the first "node_modules" directory found upwards from "script_file_dir".
    node_path_resolver = nil, ---@type fun(http_file_dir: string, script_file_dir: string, script_data: ScriptData): string|nil
  },

  ui = {
    -- display mode: possible values: "split", "float"
    display_mode = "split",
    -- split direction: possible values: "vertical", "horizontal"
    split_direction = "vertical",
    -- window options to override win_config: width/height/split/vertical.., buffer/window options
    win_opts = { bo = {}, wo = {} }, ---@type kulala.ui.win_config
    -- default view: "body" or "headers" or "headers_body" or "verbose" or fun(response: Response)
    default_view = "body", ---@type "body"|"headers"|"headers_body"|"verbose"|fun(response: Response)
    -- enable winbar
    winbar = true,
    -- Specify the panes to be displayed by default
    -- Current available pane contains { "body", "headers", "headers_body", "script_output", "stats", "verbose", "report", "help" },
    default_winbar_panes = { "body", "headers", "headers_body", "verbose", "script_output", "report", "help" },
    -- enable/disable variable info text
    -- this will show the variable name and value as float
    -- possible values: false, "float"
    show_variable_info_text = false,
    -- icons position: "signcolumn"|"on_request"|"above_request"|"below_request" or nil to disable
    show_icons = "on_request",
    -- default icons
    icons = {
      inlay = {
        loading = "⏳",
        done = "✅",
        error = "❌",
      },
      lualine = "🐼",
      textHighlight = "WarningMsg", -- highlight group for request elapsed time
    },

    -- highlight groups for http syntax highlighting
    ---@type table<string, string|vim.api.keyset.highlight>
    syntax_hl = {
      ["@punctuation.bracket.kulala_http"] = "Number",
      ["@character.special.kulala_http"] = "Special",
      ["@operator.kulala_http"] = "Special",
      ["@variable.kulala_http"] = "String",
    },

    -- enable/disable request summary in the output window
    show_request_summary = true,
    -- disable notifications of script output
    disable_script_print_output = false,

    report = {
      -- possible values: true | false | "on_error"
      show_script_output = true,
      -- possible values: true | false | "on_error" | "failed_only"
      show_asserts_output = true,
      -- possible values: true | false | "on_error"
      show_summary = true,

      headersHighlight = "Special",
      successHighlight = "String",
      errorHighlight = "Error",
    },

    -- scratchpad default contents
    scratchpad_default_contents = {
      "@MY_TOKEN_NAME=my_token_value",
      "",
      "# @name scratchpad",
      "POST https://httpbin.org/post HTTP/1.1",
      "accept: application/json",
      "content-type: application/json",
      "",
      "{",
      '  "foo": "bar"',
      "}",
    },

    disable_news_popup = false,

    -- enable/disable lua syntax highlighting
    lua_syntax_hl = true,

    -- Settings for pickers used for Environment, Authentication and Requests Managers
    pickers = {
      snacks = {
        layout = function()
          local has_snacks, snacks_picker = pcall(require, "snacks.picker")
          return not has_snacks and {}
            or vim.tbl_deep_extend("force", snacks_picker.config.layout("telescope"), {
              reverse = true,
              layout = {
                { { win = "list" }, { height = 1, win = "input" }, box = "vertical" },
                { win = "preview", width = 0.6 },
                box = "horizontal",
                width = 0.8,
              },
            })
        end,
      },
    },
  },

  lsp = {
    -- enable/disable built-in LSP server
    enable = true,

    --enable/disable/customize  LSP keymaps
    ---@type boolean|table
    keymaps = false, -- disabled by default, as Kulala relies on default Neovim LSP keymaps

    -- enable/disable/customize HTTP formatter
    formatter = {
      sort = { -- enable/disable alphabetical sorting in request body
        metadata = true,
        variables = true,
        commands = true,
        json = true,
      },
    },

    on_attach = nil, -- function called when Kulala LSP attaches to the buffer
  },

  -- enable/disable debug mode
  debug = 3,
  -- enable/disable bug reports on error
  generate_bug_report = false,

  -- set to true to enable default keymaps (check docs or {plugins_path}/kulala.nvim/lua/kulala/config/keymaps.lua for details)
  -- or override default keymaps as shown in the example below.
  ---@type boolean|table
  global_keymaps = false,
  --[[
    {
      ["Send request"] = { -- sets global mapping
        "<leader>Rs",
        function() require("kulala").run() end,
        mode = { "n", "v" }, -- optional mode, default is n
        desc = "Send request" -- optional description, otherwise inferred from the key
      },
      ["Send all requests"] = {
        "<leader>Ra",
        function() require("kulala").run_all() end,
        mode = { "n", "v" },
        ft = "http", -- sets mapping for *.http files only
      },
      ["Replay the last request"] = {
        "<leader>Rr",
        function() require("kulala").replay() end,
        ft = { "http", "rest" }, -- sets mapping for specified file types
      },
    ["Find request"] = false -- set to false to disable
    },
  ]]

  -- Prefix for global keymaps
  global_keymaps_prefix = "<leader>R",

  -- Kulala UI keymaps, override with custom keymaps as required (check docs or {plugins_path}/kulala.nvim/lua/kulala/config/keymaps.lua for details)
  ---@type boolean|table
  kulala_keymaps = true,
  --[[
    {
      ["Show headers"] = { "H", function() require("kulala.ui").show_headers() end, },
    }
  ]]

  kulala_keymaps_prefix = "",
}

return M
