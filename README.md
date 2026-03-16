# `jira-neorg.nvim`

Neovim plugin for fetching JIRA issues into [nvim-neorg/neorg](https://github.com/nvim-neorg/neorg) files.

## Features

- Fetch JIRA issues and convert them to Neorg format
- Creates a dedicated directory per issue with `issue.norg` file
- Automatically extracts issue type, status, assignee, creator, and description
- Converts HTML descriptions to Neorg-friendly text

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/jira-neorg.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg" },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "yourusername/jira-neorg.nvim",
  requires = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg" },
}
```

## Prerequisites

1. **plenary.nvim** - Required for HTTP requests
2. **neorg** - Required for workspace detection
3. **JIRA API Token**

## Setup

```lua
require("jira-neorg").setup({
    base_url = "https://yourdomain.atlassian.net",  -- No trailing slash!
    token = os.getenv("JIRA_API_TOKEN"),            -- Or provide token directly
})
```

### Configuration Options

| Option     | Type   | Default                       | Description                  |
| ---------- | ------ | ----------------------------- | ---------------------------- |
| `base_url` | string | `https://yourdomain.jira.com` | Your JIRA instance URL       |
| `token`    | string | `$JIRA_API_TOKEN`             | API token for authentication |

## Usage

### Fetch an issue

Run the command and enter a JIRA issue ID:

```
:JiraToNeorg
```

When prompted, enter an issue ID (e.g., `PROJECT-123`).

The plugin will:

1. Fetch the issue from JIRA
2. Create a directory `{issue-id}/` in your current Neorg workspace
3. Write the issue data to `issue.norg`

### Important Notes

- The `issue.norg` file is **overwritten** each time you fetch the same issue
- You must have an active Neorg workspace open
- The issue must exist and be accessible with your API token

## Example Output

Fetching `TEST-123` creates:

```
workspace/
└── TEST-123/
    └── issue.norg
```

With content:

```norg
@document.meta
title: Fix login bug
description: TEST-123
authors: John Doe
categories: [jira]
created: 2026-03-16
updated: 2026-03-16
version: 1.1.1
@end
* Issue Type
  Bug
* Status
  In Progress
* Responsibles
  Assignee: Jane Smith
  Creator:  John Doe
* Description
 The login button is not responding...
```

## Troubleshooting

**"Neorg not found!"** - Ensure Neorg is installed and loaded

**"Unauthorized"** - Check your API token is correct

**"Issue not found"** - Verify the issue ID exists and you have permission to view it

**"No workspace currently open"** - Open a Neorg workspace first with `:Neorg workspace`
