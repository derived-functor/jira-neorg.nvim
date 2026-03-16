local M = {}

M.defaults = {
    base_url = "https://yourdomain.jira.com",
    token = os.getenv("JIRA_API_TOKEN") or ""
}

M.options = {}

function M.setup(user_opts)
    user_opts = user_opts or {}

    if user_opts.base_url then
        user_opts.base_url = user_opts.base_url:gsub("/$", "")
        if not user_opts.base_url:match("^https?://") then
            vim.notify("jira-neorg: base_url must start with http:// or https://", vim.log.levels.ERROR)
            return
        end
    end

    M.options = vim.tbl_deep_extend("force", M.defaults, user_opts)
end

return M
