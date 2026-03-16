local M = {}

function M.get_issue(issue_id, token, base_url, callback)
    local curl = require("plenary.curl")
    local url = base_url .. "/rest/api/latest/issue/" .. issue_id
    local headers = {
          [ "Authorization" ] = "Bearer " .. token
        , [ "Accept" ] = "application/json"
    }
    curl.get(url, {
          headers = headers
        , timeout = 5000
        , callback = function(res)
            vim.schedule(function()
                if not res then
                    callback(nil, "No response from server")
                    return
                end

                if res.status == 401 then
                    callback(nil, "Unauthorized: check your credentials")
                    return
                elseif res.status == 404 then
                    callback(nil, "Issue not found: " .. issue_id)
                    return
                elseif res.status ~= 200 then
                    callback(nil, "HTTP error: " .. (res.status or "unknown"))
                    return
                end

                local ok, data = pcall(vim.fn.json_decode, res.body)
                if not ok then
                    callback(nil, "Failed to parse response: " .. tostring(data))
                    return
                end

                callback(data, nil)
            end)
        end
    })
end

return M
