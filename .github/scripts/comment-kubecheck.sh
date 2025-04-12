#!/bin/bash

# Fail script on errors, print each command
set -euo pipefail
set -x  # Enable command echoing for debug

# Fallback defaults
COMMIT_TIME="${COMMIT_TIME:-Unknown}"
COMMIT_MSG="${COMMIT_MSG:-(no message)}"
SUMMARY="${SUMMARY:-No summary provided.}"
RESULTS="${RESULTS:-}"
REPO="${REPO:-}"
SHA="${SHA:-}"

# Format commit message to escape backticks or special characters
ESCAPED_MSG=$(echo "$COMMIT_MSG" | sed 's/`/\\`/g')

# If no validation results, provide a placeholder
if [[ -z "$RESULTS" ]]; then
  RESULTS="_No files were validated in this run._"
fi

# Construct markdown comment
COMMENT="$(cat <<EOF
🧪 **KubeCheck Validation Results**

🕒 Commit Time: \`${COMMIT_TIME}\`  
💬 Message: _${ESCAPED_MSG}_

${SUMMARY}

---

${RESULTS}
EOF
)"

# Print comment preview for log/debugging
echo "Generated comment content:"
echo "$COMMENT"

# Escape for JSON
jq -n --arg body "$COMMENT" '{body: $body}' > comment.json

# Perform the API call and capture HTTP response
RESPONSE_FILE="curl_response.log"

curl -s -X POST "https://api.github.com/repos/${REPO}/commits/${SHA}/comments" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" \
  --data-binary @comment.json \
  -w "\n\nHTTP Status: %{http_code}\n" \
  -o "$RESPONSE_FILE"

# Output the response content to logs
echo "GitHub API response:"
cat "$RESPONSE_FILE"
