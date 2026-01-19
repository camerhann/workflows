# 🤖 Claude Agent Workflows

Automate GitHub issue resolution with a 4-agent AI pipeline powered by Claude.

**Label an issue with `agent` → Claude analyzes, codes, reviews, and creates a PR.**

---

## ✨ What It Does

When you label a GitHub issue with `agent`, this pipeline automatically:

```
┌──────────────────────────────────────────────────────────────────────────┐
│  1. ISSUE ANALYST       →  Researches codebase, creates brief            │
│  2. WRITER-REVIEWER     →  Makes changes, reviews, RETRIES if rejected   │
│     LOOP (up to 3x)        (Ralph-style self-correction)                 │
│  3. COMMITTER AGENT     →  Creates PR to develop branch                  │
└──────────────────────────────────────────────────────────────────────────┘
```

**You review the PR and merge when ready.** The agent does the work, you stay in control.

---

## 🔄 Ralph-Style Retry Loop (NEW!)

Inspired by the [Ralph Wiggum technique](https://ghuntley.com/ralph/), this pipeline now features **self-correcting agents**:

```
┌─────────────────────────────────────────────────────────────┐
│                  WRITER-REVIEWER LOOP                       │
│                                                             │
│   Attempt 1:                                                │
│     Writer ──→ code changes                                 │
│     Reviewer ──→ ❌ REJECTED: "Missing error handling"      │
│                         │                                   │
│   Attempt 2:            ▼ (feedback passed to Writer)       │
│     Writer ──→ improved code (addresses feedback)           │
│     Reviewer ──→ ❌ REJECTED: "Doesn't match pattern"       │
│                         │                                   │
│   Attempt 3:            ▼                                   │
│     Writer ──→ final improvements                           │
│     Reviewer ──→ ✅ APPROVED                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Features

| Feature | Description |
|---------|-------------|
| **Retry Loop** | Writer gets up to 3 attempts to produce approved code |
| **Feedback Flow** | Rejection reasons are passed back to Writer for next attempt |
| **Promise Signals** | Agents use `<promise>` tags for clear completion signals |
| **Iteration Tracking** | PR body shows how many attempts were needed |
| **Graceful Failure** | If all attempts fail, helpful feedback posted to issue |

### Promise Signals

Each agent outputs explicit completion signals:

```
<promise>ANALYSIS_COMPLETE</promise>     # Analyst finished research
<promise>ANALYSIS_BLOCKED: reason</promise>  # Analyst can't proceed
<promise>CHANGES_READY</promise>         # Writer finished coding
<promise>APPROVED</promise>              # Reviewer approves
<promise>REJECTED: feedback</promise>    # Reviewer rejects with feedback
<promise>PR_CREATED</promise>            # Committer finished
```

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
│   └── issue-agent.yml       # Central reusable workflow (with Ralph-style loop)
├── agents/                    # Agent definitions (for local CLI use)
│   ├── issue-analyst.md      # Research & analysis
│   ├── pr-writer.md          # Code changes
│   ├── pr-reviewer.md        # Quality gate
│   └── pr-committer.md       # Commit & PR
├── repo-setup/
│   └── issue-agent-caller.yml  # Copy this to your repos
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
- Outputs `<promise>ANALYSIS_COMPLETE</promise>` or `<promise>ANALYSIS_BLOCKED: reason</promise>`

### 2. Writer-Reviewer Loop (Ralph-Style)
> *"Self-correction through iteration."*

**Writer Agent:**
> *"The best code change is the smallest one that solves the problem."*

- Studies existing code patterns BEFORE writing
- Makes minimal, surgical changes
- On retry: receives and addresses reviewer feedback
- Outputs `<promise>CHANGES_READY</promise>`

**Reviewer Agent:**
> *"Nothing gets through unless it's verified."*

- Reviews code changes for bugs, security, patterns
- If issues found: outputs `<promise>REJECTED: specific feedback</promise>`
- If all good: outputs `<promise>APPROVED</promise>`
- **On rejection, Writer gets another attempt with the feedback!**

### 3. Committer Agent
> *"Only approved, tested code gets committed."*

- Verifies Reviewer approved
- Generates smart commit message based on changes
- Creates PR targeting `develop` branch
- PR body shows iteration count (e.g., "Approved after 2 attempts")

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

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX_WRITER_ATTEMPTS` | `3` | Maximum retry attempts for Writer-Reviewer loop |

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

### Adjusting Retry Behavior

Change the max attempts by editing the env variable:

```yaml
env:
  MAX_WRITER_ATTEMPTS: 5  # Increase to 5 attempts
```

### Agent Philosophies

The agents follow specific philosophies defined in their prompts:

| Agent | Philosophy |
|-------|------------|
| Analyst | Research first, clear briefs, no guessing |
| Writer | Minimal changes, respect existing patterns |
| Reviewer | Verify everything, provide actionable feedback |
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

### Pipeline failing after all retries?
- Check the issue comment for the final feedback
- Simplify the issue requirements
- Break into smaller, more focused issues
- Add more specific acceptance criteria

### Analyst blocking?
- The issue may be too vague
- Add more context about what needs to change
- Specify which files or components are involved

---

## 📊 Understanding PR Results

The PR body now shows iteration history:

```markdown
## Pipeline Results
- **Issue Analyst:** ✅ Research complete
- **Writer-Reviewer Loop:** 🔄 Approved after 2 attempts (Ralph-style retry)
- **Committer Agent:** ✅ PR created
```

This helps you understand:
- How much iteration was needed
- Whether the task was straightforward or required refinement
- The overall health of your issue descriptions

---

## 📄 License

MIT License - Use freely, modify as needed.

---

## 🙏 Credits

- Built with [Claude](https://anthropic.com) by Anthropic
- Inspired by the [Ralph Wiggum technique](https://ghuntley.com/ralph/) by Geoffrey Huntley

---

## 💡 Tips for Best Results

1. **Write clear issues** - The better your issue, the better the solution
2. **Include acceptance criteria** - Tell the agent what "done" looks like
3. **Mention files if known** - "Check `src/components/Button.tsx`"
4. **Set boundaries** - "Don't modify the API layer"
5. **Start small** - Test with simple issues first
6. **Trust the retry loop** - If first attempt fails, the agent will self-correct!

---

**Questions?** Open an issue in this repo!
