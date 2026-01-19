# Claude Agent Workflows

Centralized GitHub Actions workflows for automated issue resolution using Claude.

## 🚀 Quick Start

### For Existing Repos

Run the install script:
```bash
./repo-setup/install.sh /path/to/your/repo
```

Or manually:
1. Copy `repo-setup/issue-agent-caller.yml` to `.github/workflows/issue-agent.yml` in your repo
2. Create a `develop` branch
3. Add `ANTHROPIC_API_KEY` to your repo secrets

### For New Repos

1. Create repo from this template (if template is enabled)
2. Or run the install script after creating the repo

## 📁 Structure

```
workflows/
├── .github/workflows/
│   └── issue-agent.yml      # Central reusable workflow
├── agents/                   # Agent definitions (for reference)
│   ├── issue-analyst.md
│   ├── pr-writer.md
│   ├── pr-reviewer.md
│   └── pr-committer.md
├── repo-setup/
│   ├── issue-agent-caller.yml  # Copy this to your repos
│   └── install.sh              # Installation script
└── README.md
```

## 🔄 The Pipeline

When you label an issue with `agent` (or comment `@claude-agent`):

```
1. Issue Analyst    → Researches codebase, creates brief
2. Writer Agent     → Makes minimal, surgical changes
3. Reviewer Agent   → Quality gate: tests, lint, approve/reject
4. Committer Agent  → Smart commit, PR to develop branch
```

## 🌿 Branch Strategy

```
main          ← Production (merge manually)
  ↑
develop       ← Agent PRs target here
  ↑
agent/issue-X ← Agent creates these branches
```

**Flow:**
1. Agent creates PR → `develop`
2. You review and merge to `develop`
3. You manually merge `develop` → `main` when ready
4. You close the issue

## ⚙️ Requirements

Each repo needs:
- `ANTHROPIC_API_KEY` secret set
- `develop` branch created
- `.github/workflows/issue-agent.yml` (the caller)

## 🔧 Updating the Workflow

Edit `.github/workflows/issue-agent.yml` in THIS repo.
All repos using the centralized workflow will automatically get the updates!

## 📖 Agent Philosophies

### Issue Analyst
> "The Writer should never have to guess what to do."

Researches the codebase, creates structured briefs.

### Writer
> "The best code change is the smallest one that solves the problem."

Minimal, surgical changes respecting existing patterns.

### Reviewer
> "Nothing gets through unless it's verified."

Quality gatekeeper - runs tests, lint, approves or rejects.

### Committer
> "Only approved, tested code gets committed."

Smart commit messages, pushes to develop, creates PR.
