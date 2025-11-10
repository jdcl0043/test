#!/bin/bash

# AWS Archive User Setup Script
# This script automates the creation of an archive user named "Ajay"
# with appropriate permissions for backup and archive operations

set -e  # Exit on any error

# Configuration
USERNAME="ajay-archive"
POLICY_NAME="ArchiveUserPolicy"
POLICY_FILE="aws-archive-policy.json"
CONSOLE_ACCESS="true"  # Set to "false" if console access is not needed

echo "=========================================="
echo "AWS Archive User Setup Script"
echo "User: ${USERNAME}"
echo "=========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed."
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if policy file exists
if [ ! -f "${POLICY_FILE}" ]; then
    echo "Error: Policy file '${POLICY_FILE}' not found."
    echo "Please ensure the policy file exists in the current directory."
    exit 1
fi

# Check AWS credentials
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not configured or invalid."
    echo "Please run 'aws configure' first."
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: ${ACCOUNT_ID}"
echo ""

# Step 1: Create IAM user
echo "Step 1: Creating IAM user '${USERNAME}'..."
if aws iam get-user --user-name "${USERNAME}" &> /dev/null; then
    echo "Warning: User '${USERNAME}' already exists. Skipping user creation."
else
    aws iam create-user --user-name "${USERNAME}" --tags Key=Purpose,Value=Archive Key=ManagedBy,Value=Script
    echo "User '${USERNAME}' created successfully."
fi
echo ""

# Step 2: Create custom policy
echo "Step 2: Creating custom policy '${POLICY_NAME}'..."
if aws iam get-policy --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" &> /dev/null; then
    echo "Warning: Policy '${POLICY_NAME}' already exists."
    read -p "Do you want to create a new version? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Delete old policy versions if limit reached
        VERSIONS=$(aws iam list-policy-versions --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text)
        for VERSION in $VERSIONS; do
            aws iam delete-policy-version --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" --version-id "$VERSION"
        done
        aws iam create-policy-version --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" --policy-document file://"${POLICY_FILE}" --set-as-default
        echo "Policy updated with new version."
    fi
else
    POLICY_ARN=$(aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document file://"${POLICY_FILE}" --description "Archive user policy for backup and archival operations" --query 'Policy.Arn' --output text)
    echo "Policy '${POLICY_NAME}' created successfully."
    echo "Policy ARN: ${POLICY_ARN}"
fi
echo ""

# Step 3: Attach policy to user
echo "Step 3: Attaching policy to user..."
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"
if aws iam list-attached-user-policies --user-name "${USERNAME}" | grep -q "${POLICY_NAME}"; then
    echo "Policy already attached to user."
else
    aws iam attach-user-policy --user-name "${USERNAME}" --policy-arn "${POLICY_ARN}"
    echo "Policy attached successfully."
fi
echo ""

# Step 4: Create console access (optional)
if [ "${CONSOLE_ACCESS}" = "true" ]; then
    echo "Step 4: Setting up console access..."
    read -s -p "Enter password for console access (or press Enter to auto-generate): " PASSWORD
    echo ""
    
    if [ -z "${PASSWORD}" ]; then
        # Generate random password
        PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
        echo "Auto-generated password: ${PASSWORD}"
        echo "IMPORTANT: Save this password securely!"
    fi
    
    if aws iam get-login-profile --user-name "${USERNAME}" &> /dev/null; then
        echo "Console access already configured."
    else
        aws iam create-login-profile --user-name "${USERNAME}" --password "${PASSWORD}" --password-reset-required
        echo "Console access created. User must change password on first login."
    fi
else
    echo "Step 4: Skipping console access (CONSOLE_ACCESS=false)"
fi
echo ""

# Step 5: Create access keys
echo "Step 5: Creating access keys..."
read -p "Create access keys for programmatic access? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "${USERNAME}")
    ACCESS_KEY_ID=$(echo "${ACCESS_KEY_OUTPUT}" | grep -o '"AccessKeyId": "[^"]*' | cut -d'"' -f4)
    SECRET_ACCESS_KEY=$(echo "${ACCESS_KEY_OUTPUT}" | grep -o '"SecretAccessKey": "[^"]*' | cut -d'"' -f4)
    
    echo ""
    echo "=========================================="
    echo "IMPORTANT: Save these credentials securely!"
    echo "=========================================="
    echo "Access Key ID: ${ACCESS_KEY_ID}"
    echo "Secret Access Key: ${SECRET_ACCESS_KEY}"
    echo "=========================================="
    echo ""
    
    # Save to file
    CREDENTIALS_FILE="ajay-archive-credentials.txt"
    cat > "${CREDENTIALS_FILE}" << EOF
AWS Archive User Credentials
========================================
Username: ${USERNAME}
Access Key ID: ${ACCESS_KEY_ID}
Secret Access Key: ${SECRET_ACCESS_KEY}
Account ID: ${ACCOUNT_ID}
Created: $(date)
========================================

AWS CLI Configuration:
aws configure --profile ajay-archive
  Access Key ID: ${ACCESS_KEY_ID}
  Secret Access Key: ${SECRET_ACCESS_KEY}
  Default region: us-east-1
  Default output format: json
EOF
    
    echo "Credentials saved to: ${CREDENTIALS_FILE}"
    echo "WARNING: Delete this file after securely sharing with the user!"
else
    echo "Skipping access key creation."
fi
echo ""

# Step 6: Summary
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "User: ${USERNAME}"
echo "Policy: ${POLICY_NAME}"
echo "Account ID: ${ACCOUNT_ID}"
echo ""
echo "Next Steps:"
echo "1. Enable MFA for the user in AWS Console"
echo "2. Share credentials securely with Ajay"
echo "3. Have Ajay configure AWS CLI with the profile"
echo "4. Test access with: aws s3 ls --profile ajay-archive"
echo "5. Review CloudTrail logs for user activity"
echo ""
echo "For detailed documentation, see: AWS_ARCHIVE_USER_SETUP.md"
echo "=========================================="
