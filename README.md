# 🤖 Claude Agent Workflows

Automate GitHub issue resolution with a 4-agent AI pipeline powered by Claude.

**Label an issue with `agent` → Claude analyzes, codes, reviews, and creates a PR.**

---

## ✨ What It Does

When you label a GitHub issue with `agent`, this pipeline automatically:

```
┌─────────────────────────────────────────────────────────────────┐
│  1. ISSUE ANALYST    →  Researches codebase, creates brief     │
│  2. WRITER AGENT     →  Makes minimal, surgical code changes   │
│  3. REVIEWER AGENT   →  Runs tests/lint, approves or rejects   │
│  4. COMMITTER AGENT  →  Creates PR to develop branch           │
└─────────────────────────────────────────────────────────────────┘
```

**You review the PR and merge when ready.** The agent does the work, you stay in control.

---

## 🚀 Quick Start

### Option 1: Use as Template (New Repos)

1. Click **"Use this template"** on GitHub
2. Create your new repo
3. Add your `ANTHROPIC_API_KEY` to repo secrets
4. Create a `develop` branch
5. Start labeling issues with `agent`!

### Option 2: Add to Existing Repo

1. **Copy the caller workflow** to your repo:

```bash
mkdir -p .github/workflows
curl -o .github/workflows/issue-agent.yml \
  https://raw.githubusercontent.com/camerhann/workflows/main/repo-setup/issue-agent-caller.yml
```

2. **Create a `develop` branch:**

```bash
git checkout main
git checkout -b develop
git push -u origin develop
```

3. **Add your API key** to repo secrets:

```bash
gh secret set ANTHROPIC_API_KEY --repo YOUR_USERNAME/YOUR_REPO
```

4. **Commit and push:**

```bash
git add .github/workflows/issue-agent.yml
git commit -m "feat: add Claude agent workflow"
git push
```

---

## 📁 Repository Structure

```
workflows/
├── .github/workflows/
│   └── issue-agent.yml       # Central reusable workflow
├── agents/                    # Agent definitions
│   ├── issue-analyst.md      # Research & analysis
│   ├── pr-writer.md          # Code changes
│   ├── pr-reviewer.md        # Quality gate
│   └── pr-committer.md       # Commit & PR
├── repo-setup/
│   ├── issue-agent-caller.yml  # Copy this to your repos
│   └── install.sh              # Installation script
└── README.md
```

---

## 🔄 The Pipeline

### 1. Issue Analyst
> *"The Writer should never have to guess what to do."*

- Reads the issue
- Researches your codebase for relevant files
- Identifies existing patterns to follow
- Creates a structured brief with Must Do / Must NOT Do

### 2. Writer Agent
> *"The best code change is the smallest one that solves the problem."*

- Studies existing code patterns BEFORE writing
- Makes minimal, surgical changes
- Respects your codebase - doesn't "improve" unrelated code
- Self-reviews for minimalism

### 3. Reviewer Agent
> *"Nothing gets through unless it's verified."*

- Runs your tests
- Runs linting/type checks
- Evaluates if the solution actually solves the issue
- **REJECTS** if anything fails → sends back to Writer

### 4. Committer Agent
> *"Only approved, tested code gets committed."*

- Verifies Reviewer approved
- Generates smart commit message based on changes
- Creates PR targeting `develop` branch
- You merge to `main` when ready

---

## 🌿 Branch Strategy

```
main          ← Production (you merge here manually)
  ↑
develop       ← Agent PRs target here
  ↑
agent/issue-X ← Agent creates these branches
```

**Why `develop`?**
- Agent work goes to `develop` first
- You review and merge to `develop`
- When ready, you merge `develop` → `main`
- Full control over what goes to production

---

## ⚙️ Configuration

### Required Secrets

| Secret | Description |
|--------|-------------|
| `ANTHROPIC_API_KEY` | Your Claude API key from [console.anthropic.com](https://console.anthropic.com) |

### Triggers

The workflow triggers when:
- Issue is **labeled** with `agent`
- Someone **comments** `@claude-agent` on an issue

---

## 🛠️ Customization

### Fork and Modify

1. Fork this repo
2. Edit `.github/workflows/issue-agent.yml`
3. Update `repo-setup/issue-agent-caller.yml` to point to your fork
4. Customize agent prompts in the workflow

### Agent Philosophies

The agents follow specific philosophies defined in their prompts:

| Agent | Philosophy |
|-------|------------|
| Analyst | Research first, clear briefs, no guessing |
| Writer | Minimal changes, respect existing patterns |
| Reviewer | Verify everything, reject failures |
| Committer | Smart commits, proper PR workflow |

You can modify these in the workflow file to match your team's style.

---

## 📖 Local CLI Commands

You can also run the agents locally via Claude Code CLI:

```bash
# Analyze an issue
/issue-analyst 42

# Write code (after analysis)
/pr-writer

# Review changes
/pr-reviewer

# Commit and push
/pr-committer
```

Copy the agent files from `agents/` to `~/.claude/commands/` for local use.

---

## 🔧 Troubleshooting

### Workflow not triggering?
- Check the issue has the `agent` label
- Verify `ANTHROPIC_API_KEY` is set in repo secrets
- Check GitHub Actions is enabled for your repo

### PR targeting wrong branch?
- Make sure `develop` branch exists
- The workflow targets `develop` by default

### Agent making too many changes?
- The Writer is instructed to be minimal
- Check your issue description - be specific about what you want
- Add "Must NOT change" instructions to your issue

---

## 📄 License

MIT License - Use freely, modify as needed.

---

## 🙏 Credits

Built with [Claude](https://anthropic.com) by Anthropic.

---

## 💡 Tips for Best Results

1. **Write clear issues** - The better your issue, the better the solution
2. **Include acceptance criteria** - Tell the agent what "done" looks like
3. **Mention files if known** - "Check `src/components/Button.tsx`"
4. **Set boundaries** - "Don't modify the API layer"
5. **Start small** - Test with simple issues first

---

**Questions?** Open an issue in this repo!
