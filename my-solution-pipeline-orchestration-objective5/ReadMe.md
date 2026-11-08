# Objective 5 - Pipeline Orchestration
This readme will cover the implementation details.

## 1. CI/CD Pipeline Orchestration Architecture
The pipeline enforces code quality, test gating, and automated provisioning through four distinct workflows:

[Developer PR] ──► (PR Validation Workflow) ──► Spin Ephemeral PR Stack ──► Run Integration Tests
                                                                                  │
[Merge to Master] ◄───────────────────────────────────────────────────────────────┘
        │
        ▼
(Dev Deployment) ──► Build & Push to ECR ──► Apply Terraform Dev ──► Full Test Suite
        │
        ▼ (Manual Dispatch / Gate)
(Staging Deploy) ──► Apply Terraform Staging ──► Full Test Suite ──► Gate Production
        │
        ▼ (Customer "Purchase" Event / Webhook)
(Prod Onboarding) ──► Build ECR Image ──► Terraform Apply Tenant ──► Smoke Test Suite
Workflow Specifications
### 1. PR Validation (pr-validation.yml)
Trigger: pull_request against master.

Execution: Builds the container image, provisions a temporary ephemeral stack, and runs full integration tests.

Gate: Pull requests cannot be merged to master unless integration tests pass.

### 2. Dev Deployment (dev-deploy.yml)
Trigger: Automatic upon push to master.

Execution: Builds and pushes the image to Amazon ECR, applies dev.tfvars via Terraform, and invokes ./actions/run-system-test with test_type: 'full'.

Gate: Test failures flag the build and lock the staging pipeline.

### 3. Staging Deployment (staging-deploy.yml)
Trigger: Manual trigger via CLI or GitHub Actions UI (workflow_dispatch).

Execution: Deploys code to the staging cluster/namespace and executes the full integration test suite (test_type: 'full').

### 4. Production Customer Onboarding (prod-deploy.yml)
Trigger: Event-driven webhook (repository_dispatch on customer-purchased) or manual dispatch (workflow_dispatch).

Payload Inputs: company_id, company_name, company_motto.

Execution: Provisions isolated customer resources in Kubernetes and runs a lightweight production smoke test (test_type: 'smoke').

## 3. Custom GitHub Composite Actions
To mirror modular shared libraries (similar to Jenkins shared pipeline libraries), reusable execution blocks are encapsulated in native GitHub Composite Actions:

actions/build-docker/action.yml: Handles container image compilation, tagging with commit SHA / release version, and pushing OCI-compliant images to Amazon ECR.

actions/run-system-test/action.yml: Accepts an input parameter (test_type: 'full' vs test_type: 'smoke') to conditionally run either the comprehensive integration test suite for lower environments or rapid smoke validation for production tenant rollouts.

## 4. Multi-Tenant Infrastructure & Logging Strategy
Kubernetes & AWS Integration
Container Runtimes & Registry: Container images are compiled following OCI standards, uploaded to Amazon ECR, and pulled by Kubernetes (containerd runtime) to schedule pods.

Tenant Isolation: Each customer operates within an isolated namespace (tenant-<company-id>) with dedicated resource limits and ingress routing.

Personalized Onboarding Screen: A Helm/Terraform template injects customer metadata via ConfigMaps into Nginx, rendering the personalized welcome banner ("Welcome to SAS, [Company Name]! [Motto]").

Observability & Centralized Logging
Container Logs: Applications write to standard output (stdout/stderr).

CloudWatch Integration: AWS FluentBit / CloudWatch agents aggregate pod logs across all customer namespaces into AWS CloudWatch Logs for long-term persistence, cross-tenant log filtering, and error alert monitoring.