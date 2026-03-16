if vim.g.loaded_jira_neorg then return end
vim.g.loaded_jira_neorg = 1

vim.api.nvim_create_user_command("JiraToNeorg", function()
    require("jira-neorg").run()
end, {})
