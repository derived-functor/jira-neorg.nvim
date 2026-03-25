local M = {}

local config = require("jira-neorg.config")
local utils = require("jira-neorg.utils")
local api = require("jira-neorg.api")

M.setup = config.setup

local function _check_config(opts)
    if opts.base_url == "" or opts.token == "" then
        vim.notify("jira-neorg: Base URL or Token is missing!", vim.log.levels.ERROR)
        return false
    end
    return true
end

local function process_issue(issue_data, base_url, callback)
    local issue_id = issue_data.key

    local ok, link = pcall(utils.build_issue_link, base_url, issue_id)
    if not ok then
        callback("Error building link " .. tostring(link))
        return
    end

    issue_data["issue_link"] = link

    local ok, issue = pcall(utils.build_issue, issue_data)
    if not ok then
        callback("Error building issue: " .. tostring(issue))
        return
    end

    local lines = utils.build_lines(issue)

    local ok, file_path = pcall(utils.create_issue_in_current_workspace, lines, issue_id)
    if not ok then
        callback("Error creating issue in workspace: " .. tostring(file_path))
        return
    end

    callback(nil, file_path)
end

function M.fetch_issue()
    local opts = config.options

    if not _check_config(opts) then
        return
    end

    local issue_id = vim.fn.input("Issue ID:")

    if issue_id == "" then
        vim.notify("No issue id provided")
        return
    end

    api.get_issue(issue_id, opts.token, opts.base_url, function(data, err)
        if err then
            vim.notify("Jira error: " .. err, vim.log.levels.ERROR)
            return
        end

        process_issue(data, opts.base_url, function(err, file_path)
            if err then
                vim.notify(err, vim.log.levels.ERROR)
                return
            end
            vim.notify("Issue " .. issue_id .. " added to " .. file_path)
        end)
    end)
end

function M.get_all_user_issue()
    local opts = config.options

    if not _check_config(opts) then
        return
    end

    api.get_user_assigned_issues(opts.token, opts.base_url, function(data, err)
        if err then
            vim.notify("Jira error: " .. err, vim.log.levels.ERROR)
            return
        end

        if not data.issues or #data.issues == 0 then
            vim.notify("No issues found for current user")
            return
        end

        vim.notify("Fetched " .. data.total .. " issues")

        for _, issue_data in ipairs(data.issues) do
            local issue_id = issue_data.key
            process_issue(issue_data, opts.base_url, function(err, file_path)
                if err then
                    vim.notify(err, vim.log.levels.ERROR)
                    return
                end
                vim.notify("Issue " .. issue_id .. " added to " .. file_path)
            end)
        end
    end)
end

return M
