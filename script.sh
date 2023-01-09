#!/usr/bin/env bash

function create_api_token() {
    local payload="{\"token\": {\"client_id\": \"$client_id\", \"scopes\": [\"write\"]}}"

    response=$(
        curl -X POST "$domain/api/v2/oauth/tokens.json" \
            -u "$user/token:$token" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            2>/dev/null
    )

    token=$(echo "$response" | jq -r ".token.full_token")
    _exitCode=$?

    if [ $_exitCode -ne 0 ]; then
        echo "::error:: Unable to parse the response from /api/v2/oauth/tokens.json."
        exit 1
    fi

    echo "$token"
}

client_id="${ZENDESK_CLIENT_ID}"
user="${ZENDESK_USER}"
token="${ZENDESK_TOKEN}"
domain="https://${ZENDESK_SUBDOMAIN}.zendesk.com"

token=$(create_api_token)
