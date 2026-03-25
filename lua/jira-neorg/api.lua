local M = {}

local function build_headers(token)
    local headers = {
          [ "Authorization" ] = "Bearer " .. token
        , [ "Accept" ] = "application/json"
    }

    return headers
end

local function handle_response(res, callback)
    if not res then
        callback(nil, "No response from server")
        return false
    end

    if res.status == 401 then
        callback(nil, "Unauthorized: check your credentials")
        return false
    elseif res.status == 404 then
        callback(nil, "Issue not found")
        return false
    elseif res.status ~= 200 then
        callback(nil, "HTTP error: " .. (res.status or "unknown"))
        return false
    end

    local ok, data = pcall(vim.fn.json_decode, res.body)
    if not ok then
        callback(nil, "Failed to parse response: " .. tostring(data))
        return false
    end

    callback(data, nil)
    return true
end

local function make_request(url, opts, callback)
    local curl = require("plenary.curl")
    curl.get(url, vim.tbl_extend("keep", {
        headers = build_headers(opts.token),
        timeout = 5000,
        callback = function(res)
            vim.schedule(function()
                handle_response(res, callback)
            end)
        end,
    }, opts))
end

function M.get_user_assigned_issues(token, base_url, callback)
    local url = base_url .. "/rest/api/latest/search"
    make_request(url, {
        token = token,
        query = { ["jql"] = "assignee=currentUser()" },
    }, callback)
end

function M.get_issue(issue_id, token, base_url, callback)
    local url = base_url .. "/rest/api/latest/issue/" .. issue_id
    make_request(url, { token = token }, callback)
end

return M
