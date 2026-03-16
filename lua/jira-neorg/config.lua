local M = {}

M.defaults = {
    base_url = "https://yourdomain.jira.com",
    token = os.getenv("JIRA_API_TOKEN") or ""
}

M.options = {}

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
end

return M
