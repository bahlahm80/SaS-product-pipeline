# Objective 5 - Pipeline Orchestration
This readme will cover the implementation details.

## What are we solving?
We need automatic CI/CD pipeline that upon customer clicking on the "Purchase" button, it will automatically run the CI/CD pipeline
to deliver the SaS product to the customer at ease and land them to the "Welcome Page"

## Solution

### 1. CI/CD Pipeline Orchestration Architecture
The pipeline not only covers the customer onboarding phase, but the entire software development cycle from coding -> testing -> production onboarding and 
production software upgrade(existing customer).
The pipeline enforces code quality, test gating, and automated provisioning through four distinct workflows:

[Developer PR] ──► (PR Validation Workflow) ──► Spin Ephemeral PR Stack ──► Run Integration Tests
                                                                                  │
[Merge to Master] ◄───────────────────────────────────────────────────────────────┘
        │
        ▼
(Dev Deployment) ──► Build & Push to ECR and Artifactory ──► Apply Terraform Dev(Done manually once) ──► Full System Test Suite
        │
        ▼ (Manual Dispatch / Gate)
(Staging Deploy) ──► Apply Terraform Staging(Done manually once) ──► Full Test Suite ──► Gate Production
        │
        ▼ (Customer "Purchase" Event / Webhook)
(Prod Onboarding) ──► Pool artifact from Artifactory ──► Terraform Apply Tenant(Only onboarding once) ──► Smoke System Test Suite
        |
        ▼ (Existing Customer Update - triggers via new artifact version.  Deployed upon Human approval)
(Prod Update) ──► Pool artifact from Artifactory ──► Smoke System Test Suite

### 2. Workflow Specifications

#### 1. PR Validation (pr-validation.yml)
Trigger: pull_request against master.

Execution: Builds the container image, provisions a temporary ephemeral stack, and runs full integration tests.

Gate: Pull requests cannot be merged to master unless integration tests pass and pr approval from 2 teammates at least.

#### 2. Dev Deployment (dev-deploy.yml)
Trigger: Automatic upon push to master or PR approved.

Execution: Builds and pushes the image to Artifactory and invokes ./actions/run-system-test with test_type: 'full'.

Gate: Test failures flag the build and lock the staging pipeline.

#### 3. Staging Deployment (staging-deploy.yml)
Trigger: Manual trigger via CLI or GitHub Actions UI (workflow_dispatch).  Automatic trigger if Dev Deploy and validation passes.

Execution: Deploys code to the staging cluster/namespace and executes the smoke integration test suite (test_type: 'smoke').

Gate: Test failures flag the build and lock the prod pipeline.

#### 4. Production Customer Onboarding (prod-deploy.yml)
Trigger: Event-driven webhook (repository_dispatch on customer-purchased) or manual dispatch (workflow_dispatch).

Payload Inputs: company_id, company_name, company_motto.

Execution: Provisions isolated customer resources in Kubernetes and runs a lightweight production smoke test (test_type: 'smoke').

### 3. Custom GitHub Composite Actions
To mirror modular shared libraries (similar to Jenkins shared pipeline libraries), reusable execution blocks are encapsulated in native GitHub Composite Actions:

actions/build-docker/action.yml: Handles container image compilation, tagging with commit SHA / release version, and pushing OCI-compliant images to Amazon ECR.

actions/run-system-test/action.yml: Accepts an input parameter (test_type: 'full' vs test_type: 'smoke') to conditionally run either the comprehensive integration test suite for lower environments or rapid smoke validation for production tenant rollouts.

### 4. Error Handling
In the case where deployment fails, we want to capture the failure logs fast to resolve the issue.
In the pipeline, we are spitting out the error messages from GitHub, helm status and the pod error logs.
This step is defined here: [Error Logs](./prod-deploy.yml#Diagnose failure and report error (catch))


### 5. Rollbacks
When deployment fails due to any reasons, we will need to rollback if existing customer to the last good version 
or clean up the infrastructure if new onboarding customer. 

This is defined in here: [Rollback](./prod-deploy.yml)
