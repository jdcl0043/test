# Quick Start Guide: AWS Archive User for Ajay

## Fastest Way to Set Up

### Option 1: Automated Script (Recommended)

Run the automated setup script:

```bash
./setup-archive-user.sh
```

This will:
- Create IAM user `ajay-archive`
- Apply archive permissions policy
- Generate access credentials
- Save credentials to file

### Option 2: Manual Setup via AWS Console

1. **Login to AWS Console** → Navigate to IAM
2. **Create User**: Users → Add users → Username: `ajay-archive`
3. **Import Policy**: Policies → Create policy → Import JSON from `aws-archive-policy.json`
4. **Attach Policy**: Attach `ArchiveUserPolicy` to `ajay-archive`
5. **Generate Keys**: Security credentials → Create access key
6. **Enable MFA**: Security credentials → Assign MFA device (recommended)

### Option 3: AWS CLI Commands

```bash
# Create user
aws iam create-user --user-name ajay-archive

# Create policy
aws iam create-policy \
  --policy-name ArchiveUserPolicy \
  --policy-document file://aws-archive-policy.json

# Attach policy (replace ACCOUNT_ID)
aws iam attach-user-policy \
  --user-name ajay-archive \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/ArchiveUserPolicy

# Create access key
aws iam create-access-key --user-name ajay-archive
```

## What Ajay Can Do

- Upload/download files to S3 archive buckets
- Manage AWS Glacier vaults and archives
- Create and restore AWS backups
- Create EC2 and RDS snapshots
- View CloudWatch logs
- List and describe resources

## What Ajay Cannot Do

- Delete production resources
- Modify IAM users/roles
- Access billing information
- Perform administrative tasks

## Testing Access

After setup, have Ajay test their access:

```bash
# Configure profile
aws configure --profile ajay-archive

# Test S3 access
aws s3 ls --profile ajay-archive

# Test Glacier access
aws glacier list-vaults --account-id - --profile ajay-archive

# Test Backup access
aws backup list-backup-plans --profile ajay-archive
```

## Security Checklist

- [ ] MFA enabled
- [ ] Access keys created
- [ ] Credentials shared securely (not via email)
- [ ] Console password set (if needed)
- [ ] CloudTrail logging enabled
- [ ] User added to archive group (optional)

## Files Reference

- `AWS_ARCHIVE_USER_SETUP.md` - Complete detailed guide
- `aws-archive-policy.json` - IAM policy with permissions
- `setup-archive-user.sh` - Automated setup script
- `QUICK_START.md` - This file

## Support

For issues, refer to:
- Full documentation: `AWS_ARCHIVE_USER_SETUP.md`
- AWS IAM Console for troubleshooting
- CloudTrail for user activity logs

---
**Ready to start?** Run `./setup-archive-user.sh`
