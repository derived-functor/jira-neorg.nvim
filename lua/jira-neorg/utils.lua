local M = {}

function M.html_to_text(html)
    local mapping = {
        -- Entities
          [ "&nbsp;?" ] = " "
        , [ "&amp" ] = "&"
        , [ "&lt" ] = "<"
        , [ "&gt" ] = ">"
        , [ "&quot" ] = '"'
        -- Tags
        , [ "<br ?/?>" ] = "\n"
        , [ "</?b>" ] = "*"
        , [ "<li>" ] = "- "
        , [ "<[^>]+>" ] = ""
    }

    for k, v in pairs(mapping) do
        html = html:gsub(k, v)
    end

    return html
end

function M.clean_text(text)
    local to_clean = {
        [ "%z" ] = ""
        , [ "\n{2,}" ] = ""
        , [ "[\1-\8\11-\12\14-\31]" ] = ""
        , [ "\r\n?" ] = "\n"
    }

    for k, v in pairs(to_clean) do
        text = text:gsub(k, v)
    end

    return text
end

function M.format_text(text)
    local formatting = {
        [ "(https://[^ \t\n]+)" ] =  "{%1}"
    }

    for k, v in pairs(formatting) do
        text = text:gsub(k, v)
    end

    return text
end

function M.build_issue_link(base_url, issue_id)
    local link = base_url .. "/browse/" .. issue_id

    return link
end

function M.build_issue(data)
    local fields = data.fields

    local id_             = data.key
    local summary         = fields.summary
    local status          = fields.status.name
    local issue_type      = fields.issuetype.name
    local assignee        = fields.assignee and fields.assignee.displayName or "Unassigned"
    local creator         = fields.creator and fields.creator.displayName or "Unknown"
    local description_raw = fields.description
    local link            = (data.issue_link or "No link")

    local description = M.clean_text(M.html_to_text(description_raw))
    description = M.format_text(description)

    return {
        [ "id" ]              = id_,
        [ "summary" ]         = summary,
        [ "status" ]          = status,
        [ "issue_type" ]      = issue_type,
        [ "assignee" ]        = assignee,
        [ "creator" ]         = creator,
        [ "description" ]     = description,
        [ "link" ]            = link
    }
end

function M.get_workspace_path()
    local ok, neorg = pcall(require, "neorg")
    if not ok then
        vim.notify("Neorg not found! Ensure it is installed", vim.log.levels.ERROR)
        return nil
    end

    local dirman = neorg.modules.get_module("core.dirman")
    if not dirman then
        vim.notify("Neorg dirman module not loaded", vim.log.levels.ERROR)
        return nil
    end

    local current = dirman.get_current_workspace()
    if not current then
        vim.notify("No workspace currently open", vim.log.levels.ERROR)
        return nil
    end

    return current[2]
end

function M.build_lines(issue)
    local lines = {
        "@document.meta"
        , "title: " .. (issue.summary or "[No summary]")
        , "description: " .. (issue.id or "[No ID]")
        , "authors: " .. (issue.creator or "[No creator]")
        , "categories: [jira]"
        , "created: " .. os.date("%Y-%m-%d")
        , "updated: " .. os.date("%Y-%m-%d")
        , "version: 1.1.1"
        , "@end"
        , "* Link"
        , "  {" .. issue.link .. "}"
        , "* Issue Type"
        , "  " .. issue.issue_type
        , "* Status"
        , "  " .. issue.status
        , "* Responsibles"
        , "  Assignee: " .. issue.assignee
        , "  Creator:  " .. issue.creator
        , "* Description"
    }

    for _, desc_line in ipairs(vim.split(issue.description, "\n", {plain = true})) do
        table.insert(lines, " " .. desc_line)
    end

    return lines
end

function M.create_issue_in_current_workspace(lines, issue_id)
    local workspace_path = M.get_workspace_path()
    if not workspace_path then
        return nil, "Failed to get workspace path"
    end
    local directory = workspace_path .. "/jira/" .. issue_id
    local file_ = directory .. "/issue.norg"
    vim.fn.mkdir(directory, "p")
    vim.fn.writefile(lines, file_)

    return file_
end

return M
