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

function M.build_issue(data)
    local fields = data.fields

    local id_             = data.key
    local summary         = fields.summary
    local status          = fields.status.name
    local issue_type      = fields.issuetype.name
    local assignee        = fields.assignee.displayName
    local creator         = fields.creator.displayName
    local description_raw = fields.description

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
    }
end

function M.get_workspace_path()
    local ok, neorg = pcall(require, "neorg.core")
    if not ok then
        vim.notify("Neorg not found! Ensure it is installed", vim.log.levels.ERROR)
        return
    end
    local workspace = neorg.modules.get_module("core.dirman")

    return workspace.get_current_workspace()[2]
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
    local workspace_path = get_workspace_path()
    local directory = workspace_path .. "/" .. issue_id
    local file_ = directory .. "/issue.norg"
    print("Dir: " .. directory)
    print("File: " .. file_)

    vim.loop.fs_mkdir(directory, tonumber("755", 8))
    vim.fn.writefile(lines, file_)

    return file_
end

return M
