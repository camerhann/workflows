# Issue Agent State Schema

This document defines the shared state structure used for inter-agent communication in the Issue Agent pipeline.

## Overview

The state is passed between agents via a `state.json` file in the working directory. Each agent reads the current state, performs its work, and updates the state before handoff.

## State Structure

```json
{
  "version": "1.0",
  "issue": {
    "number": 42,
    "title": "Fix allocation slider not persisting values",
    "url": "https://github.com/owner/repo/issues/42",
    "type": "BUG_FIX | NEW_FEATURE | REFACTOR_STYLE",
    "original_body": "Original issue description...",
    "labels": ["bug", "frontend"]
  },
  "pipeline": {
    "started_at": "2024-01-15T10:30:00Z",
    "current_agent": "writer",
    "attempt": 1,
    "max_attempts": 3,
    "status": "in_progress | completed | failed | blocked"
  },
  "triage": {
    "completed": false,
    "scope": "SMALL | MEDIUM | LARGE",
    "complexity": "simple | moderate | complex",
    "should_proceed": true,
    "rejection_reason": null
  },
  "analysis": {
    "completed": false,
    "files": [
      {
        "path": "src/components/Slider.tsx",
        "purpose": "Main slider component",
        "action": "modify"
      }
    ],
    "patterns": [
      "State management uses React useState hooks",
      "API calls use the useApi hook from hooks/useApi.ts"
    ],
    "test_requirement": {
      "required": true,
      "type": "regression",
      "location": "tests/components/Slider.test.tsx",
      "description": "Test that slider value persists after save"
    },
    "must_do": [
      "Fix the slider value persistence on save"
    ],
    "must_not_do": [
      "Don't refactor the existing state management",
      "Don't modify the API response format"
    ],
    "brief": "Full markdown brief for writer..."
  },
  "writer": {
    "completed": false,
    "attempt": 1,
    "changes": [
      {
        "file": "src/components/Slider.tsx",
        "description": "Added debounce to onChange handler"
      }
    ],
    "test_written": true,
    "test_file": "tests/components/Slider.test.tsx",
    "summary": "Writer's summary of changes...",
    "previous_feedback": null
  },
  "build": {
    "completed": false,
    "tests_passed": false,
    "lint_passed": false,
    "type_check_passed": false,
    "errors": [],
    "commands_run": [
      { "command": "npm test", "exit_code": 0, "output": "..." },
      { "command": "npm run lint", "exit_code": 0, "output": "..." }
    ]
  },
  "review": {
    "completed": false,
    "verdict": "APPROVED | REJECTED | NEEDS_INFO",
    "findings": {
      "good": ["Minimal change", "Follows existing patterns"],
      "issues": [
        {
          "file": "src/components/Slider.tsx",
          "line": 42,
          "issue": "Missing null check",
          "severity": "major"
        }
      ]
    },
    "feedback_for_writer": null
  },
  "commit": {
    "completed": false,
    "hash": null,
    "message": null,
    "branch": "agent/issue-42",
    "pushed": false,
    "pr_created": false,
    "pr_url": null,
    "issue_closed": false
  },
  "communication": {
    "questions": [
      {
        "from": "writer",
        "to": "analyst",
        "question": "Should the debounce time be configurable?",
        "answered": false,
        "answer": null
      }
    ],
    "escalations": [
      {
        "agent": "reviewer",
        "reason": "Security-sensitive change detected",
        "requires_human": true,
        "resolved": false
      }
    ]
  },
  "learnings": {
    "session_id": "2024-01-15-issue-42",
    "observations": [
      {
        "agent": "writer",
        "type": "pattern_discovered",
        "content": "This repo uses debounce from lodash, not custom implementation"
      }
    ],
    "outcome": null
  }
}
```

## State Lifecycle

```
                    ┌──────────────┐
                    │   Triage     │
                    │  (optional)  │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │   Analyst    │
                    └──────┬───────┘
                           │
            ┌──────────────▼──────────────┐
            │                             │
            │     ┌───────────────┐       │
            │     │    Writer     │◄──────┤
            │     └───────┬───────┘       │
            │             │               │
            │     ┌───────▼───────┐       │
            │     │    Build      │       │
            │     └───────┬───────┘       │
            │             │               │
            │     ┌───────▼───────┐       │
            │     │   Reviewer    │───────┤ REJECT
            │     └───────┬───────┘       │
            │             │ APPROVE       │
            │             │               │
            └─────────────┼───────────────┘
                          │  (max 3 attempts)
                    ┌─────▼───────┐
                    │  Committer  │
                    └─────────────┘
```

## Agent State Updates

### Triage Agent
- Reads: `issue`
- Updates: `triage`, `pipeline.status`
- Can set: `triage.should_proceed = false` to stop pipeline

### Analyst Agent
- Reads: `issue`, `triage`
- Updates: `analysis`, `pipeline.current_agent`
- Required output: `analysis.brief`, `analysis.test_requirement`

### Writer Agent
- Reads: `issue`, `analysis`, `review.feedback_for_writer`
- Updates: `writer`, `pipeline.attempt`
- Must respect: `analysis.must_not_do`

### Build Agent
- Reads: `writer.changes`
- Updates: `build`
- On failure: Sets `review.feedback_for_writer` with build errors

### Reviewer Agent
- Reads: `issue`, `analysis`, `writer`, `build`
- Updates: `review`, `pipeline.status`
- On reject: Sets `review.feedback_for_writer`

### Committer Agent
- Reads: `review.verdict`, `writer`, `issue`
- Updates: `commit`, `pipeline.status`
- Only runs if: `review.verdict === "APPROVED"`

## Inter-Agent Communication

### Asking Questions
Any agent can ask a question to another:

```json
{
  "from": "writer",
  "to": "analyst",
  "question": "The analysis mentions 'existing debounce pattern' but I can't find it. Where is it?",
  "answered": false,
  "answer": null
}
```

The orchestrator will route the question and wait for an answer before continuing.

### Escalations
Agents can escalate to humans:

```json
{
  "agent": "reviewer",
  "reason": "Changes touch authentication code - requires human security review",
  "requires_human": true,
  "resolved": false
}
```

The orchestrator will pause and comment on the issue.

## State File Location

The state file is created in the working directory:
- Local: `./issue-state.json`
- GitHub Actions: `$GITHUB_WORKSPACE/issue-state.json`

## Initializing State

The orchestrator creates initial state from the issue:

```bash
# Example: Initialize from GitHub issue
gh issue view 42 --json number,title,body,labels,url > /tmp/issue.json
# Orchestrator parses this and creates state.json
```

## Reading and Writing State

Each agent should:

1. **Read state at start:**
   ```bash
   STATE=$(cat issue-state.json)
   ```

2. **Update relevant sections**

3. **Write state before handoff:**
   ```bash
   echo "$UPDATED_STATE" > issue-state.json
   ```

## Error States

### Pipeline Blocked
```json
{
  "pipeline": {
    "status": "blocked",
    "blocked_reason": "Analyst could not determine scope - unclear requirements"
  }
}
```

### Max Attempts Reached
```json
{
  "pipeline": {
    "status": "failed",
    "attempt": 3,
    "failure_reason": "Writer-Reviewer loop exhausted after 3 attempts"
  },
  "review": {
    "feedback_for_writer": "Final feedback that couldn't be addressed..."
  }
}
```
