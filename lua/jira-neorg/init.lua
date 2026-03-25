local M = {}

local config = require("jira-neorg.config")
local utils = require("jira-neorg.utils")
local api = require("jira-neorg.api")

M.setup = config.setup

local function _check_config(opts)
    if opts.base_url == "" or opts.token == "" then
        vim.notify("jira-neorg: Base URL or Token is missing!", vim.log.levels.ERROR)
        return
    end
end

function M.fetch_issue()

    local opts = config.options

    _check_config(opts)

    local token = opts.token
    local base_url = opts.base_url

    local issue_id = vim.fn.input("Issue ID:")

    if issue_id == "" then
        vim.notify("No issue id provided")
        return
    end

    api.get_issue(issue_id, token, base_url, function(data, err)
        if err then
            vim.notify("Jira error: " .. err, vim.log.levels.ERROR)
            return
        end

        local ok, link = pcall(utils.build_issue_link, base_url, issue_id)
        if not ok then
            vim.notify("Error building link " .. tostring(link), vim.log.levels.ERROR)
            return
        end

        data["issue_link"] = link

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

function M.get_all_user_issue()

    local opts = config.options

    _check_config(opts)

    local token = opts.token
    local base_url = opts.base_url

    api.get_user_assigned_issues(token, base_url, function(data, err)
        if err then
            vim.notify("Jira error: " .. err, vim.log.levels.ERROR)
            return
        end

        vim.notify("Fetched " .. data.total .. " issues")

        for i, issue_data in pairs(data.issues) do
            local issue_id = issue_data.key
            local ok, link = pcall(utils.build_issue_link, base_url, issue_id)
            if not ok then
                vim.notify("Error building link " .. tostring(link), vim.log.levels.ERROR)
                return
            end

            issue_data["issue_link"] = link

            local ok, issue = pcall(utils.build_issue, issue_data)
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
        end

    end)
end

return M
