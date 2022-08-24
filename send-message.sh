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

# Payload blocks generated in https://app.slack.com/block-kit-builder/
curl -X POST \
     -H "Content-type: application/json; charset=utf-8" \
     -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
     -d "{\"channel\":\"${channel_id}\",\"blocks\":[{\"type\": \"section\",\"text\": {\"type\": \"mrkdwn\",\"text\": \"*<${url}|${package}> deployment* :rocket: <https://github.com/${repo}/commit/${sha}|${sha}>\n${deployment_description}\"}},{\"type\": \"section\",\"fields\": [{\"type\": \"mrkdwn\",\"text\": \":sunrise: *Environment:* ${environment}\"},{\"type\": \"mrkdwn\",\"text\": \":1234: *Version:* ${version}\"},{\"type\": \"mrkdwn\",\"text\": \":label: *Ref:* ${ref}\"},{\"type\": \"mrkdwn\",\"text\": \":ninja: *Owner:* ${owner}\"},{\"type\": \"mrkdwn\",\"text\": \"<https:\/\/github.com\/${repo}/deployments\/activity_log?environment=${deployment_name}|Deployment Log>\"},{\"type\": \"mrkdwn\",\"text\": \"<https:\/\/github.com\/${repo}\/actions\/workflows\/deploy.yaml|CI Log>\"},{\"type\": \"mrkdwn\",\"text\": \"<${status_url}|Application Status>\"},{\"type\": \"mrkdwn\",\"text\": \"<https:\/\/github.com\/${repo}|${repo}>\"}],\"accessory\": {\"type\": \"image\",\"image_url\": \"https://github.com/${owner}.png\",\"alt_text\": \"Owner\"}},{\"type\":\"divider\"}]}" \
     https://slack.com/api/chat.postMessage
