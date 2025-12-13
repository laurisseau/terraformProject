#!/bin/bash
aws secretsmanager get-secret-value --secret-id sportsify-dev-secrets --query SecretString --output text | jq -r '.ANSIBLE_VAULT_PASS'