#!/bin/bash

set -e

# Fallback defaults (optional safety)
COMMIT_TIME="${COMMIT_TIME:-Unknown}"
COMMIT_MSG="${COMMIT_MSG:-(no message)}"
SUMMARY="${SUMMARY:-No summary provided.}"
RESULTS="${RESULTS:-}"

# Format commit message to escape backticks or special chars
ESCAPED_MSG=$(echo "$COMMIT_MSG" | sed 's/`/\\`/g')

# If no validation results, say so
if [[ -z "$RESULTS" ]]; then
  RESULTS="_No files were validated in this run._"
fi

COMMENT="$(cat <<EOF
🧪 **KubeCheck Validation Results**

🕒 Commit Time: \`${COMMIT_TIME}\`  
💬 Message: _${ESCAPED_MSG}_

${SUMMARY}

---

${RESULTS}
EOF
)"

# Print for debug
echo "$COMMENT"

# Escape for JSON and send
jq -n --arg body "$COMMENT" '{body: $body}' > comment.json

curl -s -X POST "https://api.github.com/repos/${REPO}/commits/${SHA}/comments" \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Content-Type: application/json" \
  --data-binary @comment.json
