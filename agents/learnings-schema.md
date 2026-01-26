# Issue Agent Learnings Schema

This document defines the structure for storing learnings from the Issue Agent pipeline. Learnings enable agents to improve over time by remembering patterns, mistakes, and successful approaches.

## Overview

The `learnings.json` file accumulates knowledge from each pipeline run. Agents read this file during planning to avoid repeating mistakes and leverage successful patterns.

## File Location

- Local: `~/.issue-agent/learnings.json`
- Per-repo: `.issue-agent/learnings.json` (gitignored)

## Structure

```json
{
  "version": "1.0",
  "last_updated": "2024-01-15T10:45:00Z",
  "statistics": {
    "total_issues": 42,
    "successful": 35,
    "failed": 5,
    "escalated": 2,
    "average_attempts": 1.4
  },
  "patterns": [
    {
      "id": "pattern-001",
      "type": "codebase",
      "description": "This repo uses lodash debounce, not custom implementations",
      "repo": "owner/bizdash",
      "discovered_at": "2024-01-15T10:45:00Z",
      "confidence": "high",
      "source_issue": 42
    }
  ],
  "mistakes": [
    {
      "id": "mistake-001",
      "description": "Forgot to check for null before accessing nested properties",
      "context": "React component props",
      "lesson": "Always add null checks when accessing props that might not be set on initial render",
      "discovered_at": "2024-01-10T14:30:00Z",
      "source_issue": 38
    }
  ],
  "successes": [
    {
      "id": "success-001",
      "issue_type": "BUG_FIX",
      "description": "Fixed slider persistence by adding debounce",
      "approach": "Identified race condition, added lodash debounce matching existing pattern",
      "attempts": 1,
      "discovered_at": "2024-01-15T10:45:00Z",
      "source_issue": 42
    }
  ],
  "failures": [
    {
      "id": "failure-001",
      "issue_number": 35,
      "reason": "Requirements were too vague - couldn't determine correct behavior",
      "final_feedback": "Writer couldn't determine if null or empty string should be returned",
      "lesson": "Escalate early when requirements have ambiguous edge cases",
      "discovered_at": "2024-01-08T09:15:00Z"
    }
  ],
  "repo_knowledge": {
    "owner/bizdash": {
      "tech_stack": ["typescript", "react", "fastapi", "python"],
      "test_framework": "pytest",
      "lint_command": "npm run lint",
      "test_command": "pytest",
      "patterns": [
        "State management uses React hooks",
        "API calls use custom useApi hook",
        "Error handling uses CustomError class"
      ],
      "gotchas": [
        "Some components expect props to be non-null on mount",
        "The allocations module has complex state - be careful with updates"
      ]
    }
  },
  "sessions": [
    {
      "session_id": "2024-01-15-issue-42",
      "issue_number": 42,
      "issue_title": "Fix allocation slider not persisting",
      "started_at": "2024-01-15T10:30:00Z",
      "completed_at": "2024-01-15T10:45:00Z",
      "outcome": "success",
      "attempts": 1,
      "agents_used": ["triage", "analyst", "writer", "builder", "reviewer", "committer"],
      "observations": [
        {
          "agent": "analyst",
          "type": "pattern_discovered",
          "content": "Found lodash debounce used in other components"
        },
        {
          "agent": "writer",
          "type": "approach_worked",
          "content": "Debounce with 300ms delay fixed the race condition"
        }
      ]
    }
  ]
}
```

## Usage by Agents

### Analyst Agent

Before researching, check learnings:
```bash
# Check for relevant patterns in this repo
cat ~/.issue-agent/learnings.json | jq '.repo_knowledge["owner/bizdash"]'

# Check for similar past issues
cat ~/.issue-agent/learnings.json | jq '.successes[] | select(.issue_type == "BUG_FIX")'
```

Include in brief: "Based on previous issues, this repo uses X pattern for Y."

### Writer Agent

Before writing code, check learnings:
```bash
# Check for mistakes to avoid
cat ~/.issue-agent/learnings.json | jq '.mistakes[]'

# Check for patterns to follow
cat ~/.issue-agent/learnings.json | jq '.patterns[] | select(.repo == "owner/bizdash")'
```

Include in approach: "Avoiding previous mistake X by doing Y."

### Orchestrator

After each pipeline run:
1. Determine outcome (success/failure/escalated)
2. Collect observations from state
3. Extract learnings
4. Append to learnings.json

## Recording Learnings

### Pattern Discovered
When an agent discovers a codebase pattern:

```json
{
  "type": "codebase",
  "description": "Error messages use i18n keys, not hardcoded strings",
  "repo": "owner/bizdash",
  "confidence": "high",
  "source_issue": 42
}
```

### Mistake Made
When a retry was needed due to an error:

```json
{
  "description": "Added feature flag check but forgot the fallback for flag not existing",
  "context": "Feature flag evaluation",
  "lesson": "Always provide default value when checking feature flags"
}
```

### Successful Approach
When something worked well:

```json
{
  "issue_type": "NEW_FEATURE",
  "description": "Added export button to dashboard",
  "approach": "Followed existing button component pattern, reused CSV utility",
  "attempts": 1
}
```

### Failure Analysis
When pipeline fails after max retries:

```json
{
  "issue_number": 35,
  "reason": "Could not determine correct error handling approach",
  "final_feedback": "Reviewer rejected: inconsistent with existing error patterns",
  "lesson": "When multiple error handling patterns exist, ask which to use"
}
```

## Confidence Levels

- **high**: Pattern observed multiple times, always holds
- **medium**: Pattern observed once, seems reliable
- **low**: Pattern suspected but not confirmed

## Retention Policy

- Keep last 100 sessions
- Keep all patterns (they don't expire)
- Keep last 50 mistakes (learning from mistakes)
- Keep last 50 successes (for reference)
- Keep all failures (important to remember)

## Privacy

The learnings file may contain:
- Issue numbers and titles (public info)
- Code patterns (not actual code)
- Error messages (may be sensitive)

For sensitive repos, use per-repo learnings file that's gitignored.

## Initialization

If learnings.json doesn't exist, create with defaults:

```json
{
  "version": "1.0",
  "last_updated": null,
  "statistics": {
    "total_issues": 0,
    "successful": 0,
    "failed": 0,
    "escalated": 0,
    "average_attempts": 0
  },
  "patterns": [],
  "mistakes": [],
  "successes": [],
  "failures": [],
  "repo_knowledge": {},
  "sessions": []
}
```
