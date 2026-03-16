local M = {}

local config = require("jira-neorg.config")
local utils = require("jira-neorg.utils")
local api = require("jira-neorg.api")

M.setup = config.setup

function M.run()

    local issue_id = vim.fn.input("Issue ID:")

    if issue_id == "" then
        vim.notify("No issue id provided")
        return
    end


    local opts = config.options
    if opts.base_url == "" or opts.token == "" then
        vim.notify("jira-neorg: Base URL or Token is missing!", vim.log.levels.ERROR)
        return
    end

    local token = opts.token
    local base_url = opts.base_url


    api.get_issue(issue_id, token, base_url, function(data, err)
        if err then
            vim.notify("Jira error: " .. err, vim.log.levels.ERROR)
            return
        end

        local ok, issue = pcall(utils.build_issue, data)
        if not ok then
            vim.notify("Error building issue" .. tostring(issue), vim.log.levels.ERROR)
            return
        end

        local lines = utils.build_lines(issue)

        local ok, file_ = pcall(utils.create_issue_in_current_workspace, lines, issue_id)
        if not ok then
            vim.notify("Error creating issue in workspace: " .. tostring(file_), vim.log.levels.ERROR)
            return
        end

        vim.notify("Issue " .. issue_id .. " added to " .. file_)
    end)

end

return M
