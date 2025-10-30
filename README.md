# AWS RDS Database Provisioning with Port using GitLab Pipeline

This repository contains a GitLab CI/CD pipeline that provisions AWS RDS database instances through Port actions. The pipeline creates databases dynamically with unique naming, quota checking, and full Port integration for tracking.

## 🏗️ Architecture

The pipeline consists of 5 stages:
1. **Prerequisites**: Port authentication, quota checking, and unique name generation
2. **Terraform**: Infrastructure provisioning with Terraform
3. **Port Update**: Success notification back to Port

## 📋 Prerequisites

### 1. Port Setup

#### RDS Blueprint
Create the following blueprint in your Port instance:

```json
{
  "identifier": "rdsDbInstance",
  "title": "RDS DB Instance",
  "icon": "AWS",
  "schema": {
    "properties": {
      "dbInstanceIdentifier": {
        "title": "DB Instance Identifier",
        "type": "string"
      },
      "dbInstanceArn": {
        "title": "DB Instance ARN",
        "type": "string"
      },
      "engine": {
        "title": "Engine",
        "type": "string"
      },
      "dbInstanceClass": {
        "title": "DB Instance Class",
        "type": "string"
      },
      "dbInstanceStatus": {
        "title": "DB Instance Status",
        "type": "string"
      },
      "multiAZ": {
        "title": "Multi-AZ",
        "type": "boolean"
      },
      "storageEncrypted": {
        "title": "Storage Encrypted",
        "type": "boolean"
      }
    },
    "required": [
      "dbInstanceIdentifier",
      "dbInstanceArn", 
      "engine",
      "dbInstanceClass",
      "dbInstanceStatus",
      "multiAZ",
      "storageEncrypted"
    ]
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "aggregationProperties": {},
  "relations": {
    "account": {
      "title": "Account",
      "target": "awsAccount",
      "required": false,
      "many": false
    }
  }
}
```

#### Port Action
Create the Port action that triggers this GitLab pipeline, found here: [port-ssa.json](./port-ssa.json)

### 2. GitLab CI/CD Variables

Set the following variables in your GitLab project:

#### Required GitLab Variables:
- `PORT_CLIENT_ID` - Port API client ID
- `PORT_CLIENT_SECRET` - Port API client secret  
- `AWS_ACCESS_KEY_ID` - AWS access key with RDS permissions
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `DB_PASSWORD` - Master password for RDS instances

#### Optional Variables:
- `AWS_DEFAULT_REGION` - AWS region (defaults to eu-west-2)

## Using with GitLab On-Premises (Self-Hosted)

If you are using a self-hosted GitLab instance, you must use the **Port execution agent** instead of the webhook backend. The agent securely triggers pipelines in your on-premises GitLab via Kafka.

**Steps:**
1. **Install the Port execution agent** using Helm and configure it with your Kafka and Port credentials, as well as your GitLab trigger token and self-hosted GitLab URL. See [official instructions](https://docs.port.io/actions-and-automations/setup-backend/gitlab-pipeline/self-hosted/).
2. **In Port,** set the action backend type to **Run GitLab Pipeline** (not Webhook) and provide your project, group/subgroup, and default ref.

> Do not use the SaaS webhook URL format for on-premises GitLab. For full details, refer to the [self-hosted GitLab setup guide](https://docs.port.io/actions-and-automations/setup-backend/gitlab-pipeline/self-hosted/#configure-the-backend).
