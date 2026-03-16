# `jira-neorg.nvim`

Simple plugin for fetching issues from JIRA to nvim-neorg/neorg files.

## Dependencies

1. nvim-lua/plenary.nvim
2. nvim-neorg/neorg

## Setup

Configuration is pretty simple:

```lua
require("jira-neorg").setup({
    base_url = "https://yourdomain.jira.com",  -- No slash on the end!
    token = "your_token" -- You can provide it directly or by env variable JIRA_API_TOKEN
})
```

## Usage

### Fetch issue

For fetching issue you can just use command `JiraToNeorg` then provide id of issue like `TEST-123`.
After this in your current workspace of neorg will be created a directory `TEST-123` and file `issue.norg` in it.

After every usage `issue.norg` will be rewritten, so be careful with that.
