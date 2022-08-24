#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if test -z "$SLACK_BOT_TOKEN"; then
  echo "Set the SLACK_BOT_TOKEN secret."
  exit 1
fi

channel_id=$1
url=$2
package=$3
environment=$4
version=$5
ref=$6
owner=$7
repo=$8
sha=$9
status_url=${10}
deployment_name=${11}
deployment_description=${12}

title="*<${url}|${package}> deployment* :rocket: <https://github.com/${repo}/commit/${sha}|${sha:7:7}>"
description="${deployment_description%$'\n'*}"
json_fmt=$(jq -n \
  --arg channelId "${channel_id}" \
  --arg title "${title}" \
  --arg description "$(sed -e 's/^"//' -e 's/"$//' -e 's/\\n/\n/g'<<<"$description")" \
  --arg envField ":sunrise: *Environment:* <https://github.com/${repo}/deployments/activity_log?environment=${environment}|${environment}>" \
  --arg versionField ":1234: *Version:* <https://github.com/${repo}/tree/${version}|${version}>" \
  --arg refField ":1234: *Ref:* ${ref}" \
  --arg ownerField ":crown: *Owner:* <https://github.com/${owner}|@${owner}>" \
  --arg deploymentLogUrl "<https://github.com/${repo}/deployments/activity_log?environment=${deployment_name}|Deployment Log>" \
  --arg ciLogUrl "<https://github.com/${repo}/actions/workflows/deployment.yaml|CI Log>"\
  --arg appStatusUrl "<${status_url}|Application Status>" \
  --arg repoUrl "<https://github.com/${repo}|${repo}>" \
  --arg imageUrl "https://github.com/${owner}.png" \
  '{"channel":$channelId,"blocks":[{"type": "section","text": {"type": "mrkdwn","text": $title}},{"type": "section","text": {"type": "mrkdwn","text": $description}},{"type": "section","fields": [{"type": "mrkdwn","text": $envField},{"type": "mrkdwn","text": $versionField},{"type": "mrkdwn","text": $refField},{"type": "mrkdwn","text": $ownerField},{"type": "mrkdwn","text": $deploymentLogUrl},{"type": "mrkdwn","text": $ciLogUrl},{"type": "mrkdwn","text": $appStatusUrl},{"type": "mrkdwn","text": $repoUrl}],"accessory": {"type": "image","image_url": $imageUrl,"alt_text": "Owner"}},{"type":"divider"}]}')

echo "$json_fmt"

# Payload blocks generated in https://app.slack.com/block-kit-builder/
curl -X POST \
     -H "Content-type: application/json; charset=utf-8" \
     -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
     -d "$json_fmt" \
     https://slack.com/api/chat.postMessage
