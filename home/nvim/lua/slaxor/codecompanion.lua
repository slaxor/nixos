require("codecompanion").setup({
  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        env = {
          url = "http://127.0.0.1:11434",
        },
        headers = {
          ["Content-Type"] = "application/json",
        },
        parameters = {
          sync = true,
        },
      })
    end,
  },
  display = {
    diff = {
      provider = "mini_diff",
    },
  },
  opts = {
    log_level = "DEBUG",
    ---@param adapter CodeCompanion.Adapter
    ---@return string
    system_prompt = function(opts)
      if opts.adapter.schema.model.default == "llama3.1:latest" then
        return "My custom system prompt"
      end
      return "My default system prompt"
    end
  },
})
