#!/usr/bin/env bash

function panic() {
    local _message="$1"

    echo "e: $_message" >&2
    exit 1
}

function info() {
    local _message="$1"

    echo "i: $_message"
}

function binary_exists() {
    local _binary="$1" _path _exitCode

    _path=$(command -v "$_binary")
    _exitCode=$?

    if [ $_exitCode -ne 0 ]; then
        return 1
    elif ! [ -x "$_path" ]; then
        return 1
    fi

    return 0
}

function env_exists() {
    local name="$1"

    if [ -z "${!name}" ]; then
        return 1
    fi

    return 0
}

function check_dependencies() {
    binary_exists "jq" || panic "jq is either not available in your \$PATH or without execution privileges!"
    binary_exists "curl" || panic "curl is either not available in your \$PATH or without execution privileges!"

    env_exists "ZENDESK_SUBDOMAIN" || panic "\$ZENDESK_SUBDOMAIN is null or empty!"
    env_exists "ZENDESK_TOKEN" || panic "\$ZENDESK_TOKEN is null or empty!"
    env_exists "ZENDESK_USER" || panic "\$ZENDESK_USER is null or empty!"
    env_exists "ZENDESK_CLIENT_ID" || panic "\$ZENDESK_CLIENT_ID is null or empty!"
}

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
        panic "Unable to parse the response from /api/v2/oauth/tokens.json."
    fi

    echo "$token"
}

check_dependencies

client_id="${ZENDESK_CLIENT_ID}"
user="${ZENDESK_USER}"
token="${ZENDESK_TOKEN}"

domain="https://${ZENDESK_SUBDOMAIN}.zendesk.com"
info "Using $domain/ as the domain."

token=$(create_api_token)
info "Token $token created!"
