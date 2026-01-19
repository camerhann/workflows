#!/bin/bash
# Install the Issue Agent workflow into a repository
# Usage: ./install.sh /path/to/repo

REPO_PATH="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Installing Issue Agent workflow to: $REPO_PATH"

# Create .github/workflows directory if it doesn't exist
mkdir -p "$REPO_PATH/.github/workflows"

# Copy the caller workflow
cp "$SCRIPT_DIR/issue-agent-caller.yml" "$REPO_PATH/.github/workflows/issue-agent.yml"

# Create develop branch if it doesn't exist
cd "$REPO_PATH"
if ! git show-ref --verify --quiet refs/heads/develop; then
    echo "📦 Creating develop branch..."
    git checkout main 2>/dev/null || git checkout master
    git checkout -b develop
    git push -u origin develop 2>/dev/null || echo "⚠️  Could not push develop branch (may need to push manually)"
    git checkout -
fi

echo "✅ Done! The repo now has:"
echo "   - .github/workflows/issue-agent.yml (calls central workflow)"
echo "   - develop branch (target for agent PRs)"
echo ""
echo "⚠️  Make sure ANTHROPIC_API_KEY is set in repo secrets!"
