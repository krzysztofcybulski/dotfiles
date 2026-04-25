#!/usr/bin/env bash
# Register MCP servers for Claude Code (user scope).
# Run once after `claude` CLI is installed and you've signed in.
#
# Required env vars (export before running, or the script will skip):
#   GITHUB_PAT       — GitHub personal access token
#   SUPABASE_PAT     — Supabase access token
#   ATLASSIAN_TOKEN  — (optional) Atlassian API token for Jira

set -uo pipefail

step() { printf "\n\033[1;35m▸ %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m! %s\033[0m\n" "$*"; }

if ! command -v claude &>/dev/null; then
  warn "claude CLI not on PATH. Install Claude Code first."
  exit 1
fi

# ----------------------------------------------------------------------------
# GitHub
# ----------------------------------------------------------------------------
if [ -n "${GITHUB_PAT:-}" ]; then
  step "Adding GitHub MCP"
  claude mcp add --transport http github https://api.githubcopilot.com/mcp \
    -H "Authorization: Bearer $GITHUB_PAT" --scope user
else
  warn "GITHUB_PAT not set — skipping GitHub MCP"
fi

# ----------------------------------------------------------------------------
# Context7 — up-to-date library docs
# ----------------------------------------------------------------------------
step "Adding Context7 MCP"
claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp@latest

# ----------------------------------------------------------------------------
# Playwright
# ----------------------------------------------------------------------------
step "Adding Playwright MCP"
claude mcp add playwright --scope user -- npx -y @playwright/mcp@latest

# ----------------------------------------------------------------------------
# Supabase
# ----------------------------------------------------------------------------
if [ -n "${SUPABASE_PAT:-}" ]; then
  step "Adding Supabase MCP"
  claude mcp add supabase --scope user -- \
    npx -y @supabase/mcp-server-supabase@latest \
    --access-token "$SUPABASE_PAT"
else
  warn "SUPABASE_PAT not set — skipping Supabase MCP"
fi

# ----------------------------------------------------------------------------
# Jira (Atlassian)
# ----------------------------------------------------------------------------
# Atlassian's official remote MCP requires you to sign in via OAuth in Claude.
# Self-host alternative: sooperset/mcp-atlassian.
if [ -n "${ATLASSIAN_TOKEN:-}" ] && [ -n "${ATLASSIAN_EMAIL:-}" ] && [ -n "${ATLASSIAN_DOMAIN:-}" ]; then
  step "Adding Jira MCP (sooperset/mcp-atlassian)"
  claude mcp add jira --scope user -- \
    docker run -i --rm \
      -e CONFLUENCE_URL="https://${ATLASSIAN_DOMAIN}.atlassian.net/wiki" \
      -e CONFLUENCE_USERNAME="$ATLASSIAN_EMAIL" \
      -e CONFLUENCE_API_TOKEN="$ATLASSIAN_TOKEN" \
      -e JIRA_URL="https://${ATLASSIAN_DOMAIN}.atlassian.net" \
      -e JIRA_USERNAME="$ATLASSIAN_EMAIL" \
      -e JIRA_API_TOKEN="$ATLASSIAN_TOKEN" \
      ghcr.io/sooperset/mcp-atlassian:latest
else
  warn "ATLASSIAN_TOKEN/EMAIL/DOMAIN not all set — skipping Jira MCP"
  warn "Alternative: add the official Atlassian remote MCP via:"
  warn "  claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/sse --scope user"
fi

# ----------------------------------------------------------------------------
# Craft — TODO
# ----------------------------------------------------------------------------
warn "Craft has no official MCP server (as of 2026-04). Skipping."
warn "Watch https://github.com/lucabotti/craft-mcp or similar community efforts."

# ----------------------------------------------------------------------------
# Verify
# ----------------------------------------------------------------------------
step "Configured MCP servers:"
claude mcp list
