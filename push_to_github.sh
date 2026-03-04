#!/bin/bash
# ── LOVE VAULT — Push all files to GitHub ──────────────────────
# Replace YOUR_TOKEN and YOUR_USERNAME before running

TOKEN="YOUR_TOKEN_HERE"
USERNAME="YOUR_GITHUB_USERNAME"
REPO="melvineAI"

API="https://api.github.com/repos/$USERNAME/$REPO/contents"
HEADERS=(-H "Authorization: token $TOKEN" -H "Content-Type: application/json")

push_file() {
  local filepath="$1"
  local repo_path="$2"
  local msg="$3"

  local content=$(base64 -w 0 "$filepath")

  # Check if file already exists (to get SHA for update)
  local sha=$(curl -s "${HEADERS[@]}" "$API/$repo_path" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sha',''))" 2>/dev/null)

  local payload
  if [ -n "$sha" ]; then
    payload="{\"message\":\"$msg\",\"content\":\"$content\",\"sha\":\"$sha\"}"
  else
    payload="{\"message\":\"$msg\",\"content\":\"$content\"}"
  fi

  local result=$(curl -s -X PUT "${HEADERS[@]}" -d "$payload" "$API/$repo_path")
  local status=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content',{}).get('name','error: '+str(d.get('message',d))))" 2>/dev/null)
  echo "  ✦ $repo_path → $status"
}

echo "🌙 Pushing Love Vault files to github.com/$USERNAME/$REPO ..."
echo ""

# Backend server
push_file "/home/claude/vault-server/index.js"   "server/index.js"   "feat: love vault backend server"
push_file "/home/claude/vault-server/package.json" "server/package.json" "feat: server dependencies"

# Frontend
push_file "/mnt/user-data/outputs/our-secret-place-v2.html" "frontend/our-secret-place-v2.html" "feat: secret vault frontend v2"
push_file "/mnt/user-data/outputs/our-secret-place.html"    "frontend/our-secret-place-v1.html" "feat: secret vault frontend v1"

# Melvine AI Agent files
push_file "/mnt/user-data/outputs/melvine-agent-v3.html" "agent/melvine-agent-v3.html" "feat: melvine AI agent v3"
push_file "/mnt/user-data/outputs/melvine-agent-v2.html" "agent/melvine-agent-v2.html" "feat: melvine AI agent v2"
push_file "/mnt/user-data/outputs/melvine-agent.html"    "agent/melvine-agent-v1.html" "feat: melvine AI agent v1"

echo ""
echo "✅ Done! View at: https://github.com/$USERNAME/$REPO"
