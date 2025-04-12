#!/bin/bash

set -e

COMMENT="$(cat <<EOF
🧪 **KubeCheck Validation Results**

🕒 Commit Time: \`${COMMIT_TIME}\`  
💬 Message: _${COMMIT_MSG}_

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
