#!/bin/bash

# Script to login to multiple MEGA accounts
# Expects EMAIL_PASSWORD_PAIRS environment variable in JSON format:
# EMAIL_PASSWORD_PAIRS='[{"email": "email1", "password": "password1"}, {"email": "email2", "password": "password2"}]'

set -e

# Check if EMAIL_PASSWORD_PAIRS is set
if [ -z "$EMAIL_PASSWORD_PAIRS" ]; then
    echo "ERROR: EMAIL_PASSWORD_PAIRS environment variable is not set."
    echo "Expected format: [{"email": "email@example.com", "password": "pass123"}]"
    exit 1
fi

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is required but not installed. Install it with: apt-get install jq"
    exit 1
fi

# Check if mega-login is available
if ! command -v mega-login &> /dev/null; then
    echo "ERROR: MEGAcmd is not installed. Please install it first."
    exit 1
fi

echo "Parsing account pairs..."

# Get the number of accounts
ACCOUNT_COUNT=$(echo "$EMAIL_PASSWORD_PAIRS" | jq '. | length')
echo "Found $ACCOUNT_COUNT account(s) to process"
echo ""

SUCCESS_COUNT=0
FAILED_COUNT=0

# Loop through each account
for i in $(seq 0 $(($ACCOUNT_COUNT - 1))); do
    EMAIL=$(echo "$EMAIL_PASSWORD_PAIRS" | jq -r ".[$i].email")
    PASSWORD=$(echo "$EMAIL_PASSWORD_PAIRS" | jq -r ".[$i].password")
    
    # Fully mask the email for security
    MASKED_EMAIL="***"
    
    echo "[$(($i + 1))/$ACCOUNT_COUNT] Attempting login for $MASKED_EMAIL"
    
    # Logout first to ensure clean state
    mega-logout 2>/dev/null || true
    
    # Attempt login and capture output
    if mega-login "$EMAIL" "$PASSWORD" 2>&1 | grep -q "Login complete\|Fetching nodes"; then
        echo "✓ Login successful for $MASKED_EMAIL"
        SUCCESS_COUNT=$(($SUCCESS_COUNT + 1))
        
        # Logout after successful login to free the session
        mega-logout 2>/dev/null || true
    else
        echo "✗ Failed to log in for $MASKED_EMAIL"
        FAILED_COUNT=$(($FAILED_COUNT + 1))
    fi
    
    echo ""
    
    # Add delay between login attempts to avoid rate limiting
    if [ $i -lt $(($ACCOUNT_COUNT - 1)) ]; then
        echo "  - Waiting 3 seconds before next login..."
        sleep 3
        echo ""
    fi
done

echo "============================================================"
echo "Summary: $SUCCESS_COUNT/$ACCOUNT_COUNT successful logins"
echo "============================================================"

# Exit with error if all logins failed
if [ $SUCCESS_COUNT -eq 0 ]; then
    exit 1
fi

exit 0
