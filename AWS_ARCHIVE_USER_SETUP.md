# AWS Archive User Setup for Ajay

## Overview
This guide provides step-by-step instructions to set up an AWS account for "Ajay" as an archive user with appropriate permissions for archiving and backup operations.

## Prerequisites
- AWS Account with administrator access
- AWS CLI installed and configured
- IAM permissions to create users and policies

## Step 1: Create IAM User via AWS Console

### Using AWS Management Console:
1. Log in to AWS Management Console
2. Navigate to **IAM** (Identity and Access Management)
3. Click on **Users** in the left sidebar
4. Click **Add users** button
5. Enter username: `ajay-archive`
6. Select access type:
   - ✓ **Programmatic access** (for AWS CLI/SDK access)
   - ✓ **AWS Management Console access** (if console access needed)
7. Set a secure password or auto-generate one
8. Click **Next: Permissions**

## Step 2: Create Custom Archive Policy

Create a custom IAM policy with archive-specific permissions:

1. In IAM, go to **Policies** → **Create policy**
2. Use the JSON policy provided in `aws-archive-policy.json`
3. Name it: `ArchiveUserPolicy`
4. Add description: "Policy for archive operations including S3 Glacier, backups, and read-only access"

## Step 3: Attach Policy to User

1. Go back to the user `ajay-archive`
2. Click **Add permissions** → **Attach policies directly**
3. Search and select:
   - `ArchiveUserPolicy` (custom policy)
   - `AWSBackupOperatorAccess` (AWS managed policy - optional)
4. Click **Next** and **Add permissions**

## Step 4: Set Up MFA (Recommended)

1. Select user `ajay-archive`
2. Go to **Security credentials** tab
3. Click **Assign MFA device**
4. Choose MFA device type (Virtual MFA, Hardware, etc.)
5. Follow the setup wizard

## Step 5: Generate Access Keys

For programmatic access:
1. In user's **Security credentials** tab
2. Scroll to **Access keys**
3. Click **Create access key**
4. Choose use case: **CLI** or **Application**
5. Download and securely store the credentials
6. **IMPORTANT**: Share credentials securely with Ajay

## Step 6: Configure AWS CLI (For Ajay)

Ajay should configure their local AWS CLI:

```bash
aws configure --profile ajay-archive
# Enter Access Key ID
# Enter Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter default output format (e.g., json)
```

## Step 7: Test Access

Test the archive user permissions:

```bash
# List S3 buckets
aws s3 ls --profile ajay-archive

# List Glacier vaults
aws glacier list-vaults --account-id - --profile ajay-archive

# Check backup plans
aws backup list-backup-plans --profile ajay-archive
```

## Security Best Practices

1. **Enable MFA**: Always use multi-factor authentication
2. **Rotate Keys**: Rotate access keys every 90 days
3. **Principle of Least Privilege**: Only grant necessary permissions
4. **Monitor Activity**: Enable CloudTrail logging
5. **Use IAM Roles**: Consider using IAM roles instead of long-term credentials
6. **Secure Credentials**: Never commit credentials to version control

## Archive Operations Ajay Can Perform

With the archive policy, Ajay can:
- Upload files to S3 and transition to Glacier
- Create and manage Glacier vaults
- Create backup plans and restore points
- Read/list resources across services
- Download archived data
- Manage lifecycle policies for archival

## Limitations

Ajay will NOT be able to:
- Delete production resources
- Modify critical infrastructure
- Access billing information
- Create or modify IAM users/roles
- Perform administrative tasks

## Troubleshooting

### Access Denied Errors
- Verify policy is correctly attached
- Check if MFA is required but not configured
- Ensure resource-level permissions are set

### Cannot Assume Role
- Verify trust policy if using roles
- Check if MFA condition is blocking access

### CLI Configuration Issues
- Verify credentials are correctly entered
- Check region configuration
- Ensure profile name matches usage

## Cost Considerations

- S3 Glacier storage: Low cost for long-term storage
- Data retrieval charges apply
- API requests are charged per operation
- Monitor costs using AWS Cost Explorer

## Additional Resources

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [S3 Glacier Documentation](https://docs.aws.amazon.com/glacier/)
- [AWS Backup Documentation](https://docs.aws.amazon.com/aws-backup/)
- [IAM Policy Simulator](https://policysim.aws.amazon.com/)

## Support

For issues or questions:
- AWS Support Center
- AWS Documentation
- Internal DevOps team

---
**Last Updated**: 2025-11-10
**Maintained By**: DevOps Team
