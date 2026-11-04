# SAS Interview Challenge

## Problem Statement

You are working for a SaaS company where customers can purchase your product.
When a customer completes their purchase, an automated pipeline should be triggered
that onboards them to the platform.

**The Goal:**
When the pipeline completes, the customer should be able to view a personalized
welcome screen that displays:

- Their company name
- Their company motto
- A "Welcome to SAS" message

**Scale Requirements:**

- Handle onboarding for 10-100 customers efficiently  
- Pipeline should be automated and reliable
- Solution should accommodate customer-specific data
- Consider how this scales as your customer base grows

## What We're Looking For

We want to see your DevOps thinking and problem-solving approach. You should:

- **Select 2-3 objectives** from the list below that interest you most
- **Create a script/solution** in any language you prefer (bash, python, groovy,
  yaml, etc.)
- **Demonstrate your understanding** of the chosen concepts
- **Document your approach** and reasoning

*Note: This does NOT need to be runnable code - pseudo code and well-commented
scripts are perfectly acceptable.*

## 10 Key Objectives to Consider

Choose a few objectives that align with your interests and expertise:

### 1. **Input Management**

Design how customer purchase events and metadata enter the pipeline. Define input
validation/normalization rules, idempotency to prevent duplicates, and secure
PII handling. Specify error handling, retry/backoff, and dead-letter routing for
malformed payloads.

### 2. **Data Deployment to Web Servers**

Design a mechanism for deploying customer-specific data (company name, motto) to
backend web servers running in Kubernetes. Consider how to package data into ConfigMaps
or Secrets, update pod configurations, and manage rolling deployments across multiple
web server pods without downtime.

### 3. **Data Management & Storage**

Design how to store and retrieve customer information (company names, mottos,
preferences). Consider databases, data validation, and data security.

### 4. **Scalable Web Serving**

Implement a Kubernetes-based web serving solution that can handle personalized pages
for 10-100+ customers. Consider pod autoscaling, service mesh configurations, ingress
controllers, and how to efficiently route traffic to customer-specific deployments.

### 5. **Pipeline Orchestration**

Design the workflow that coordinates all onboarding steps from purchase completion
to live customer page. Consider using tools like Github Workflows or Github Actions.
Along with task queues, error handling, and process monitoring.

### 6. **Security & Access Control**

Address security concerns for customer data and personalized pages. Consider
authentication, authorization, data encryption, and secure customer isolation.

### 7. **Monitoring & Health Checks**

Implement monitoring for the onboarding pipeline and customer pages running in
Kubernetes. Consider Prometheus metrics, Grafana dashboards, pod health checks,
service monitoring, and alerting for failed onboardings using tools like AlertManager.

### 8. **Configuration Management**

Design a system for managing customer-specific configurations in Kubernetes using
ConfigMaps, Secrets, and custom resources. Consider Helm charts for templating,
Kustomize overlays, and feature flags that might vary per customer tier or package.

### 9. **Infrastructure as Code**

Design Kubernetes infrastructure provisioning using tools like Terraform, Pulumi,
or GitOps with ArgoCD/Flux. Consider cluster setup, namespace management, RBAC
policies, and how to scale infrastructure for hosting customer pages and running
onboarding pipelines.

### 10. **Error Handling & Recovery**

Implement robust error handling for failed onboardings, partial completions, and
recovery mechanisms. Consider retry logic, manual intervention processes, and
customer communication.

## Your Deliverable

Create a folder/file structure that demonstrates your chosen objectives. For example:

- `my-solution/` directory
- Implementation script(s) in your preferred language
- Documentation explaining your approach
- Any configuration files or templates needed

## Notes Section

*Use this space as your scratch pad for ideas, architecture diagrams (ASCII art
welcome!), or planning notes.*

---

### Planning Notes

```text
Add your thoughts here...

Customer Data Flow:
- How does customer purchase data reach the pipeline?
- Where do we store company name and motto?
- 

Pipeline Trigger Ideas:
- API webhook from purchase system?
- Queue-based processing?
- 

Technology Choices:
- Database for customer data?
- Pipeline orchestration tool?
- 

Challenges to Address:
- What if onboarding fails mid-process?
- How to handle duplicate company names?
- 

```

### Architecture Sketches

```text
Draw your customer onboarding flow here...

Purchase -> Pipeline -> Personalized Page

Customer Journey:
1. Customer completes purchase
2. System captures company name + motto  
3. Pipeline generates personalized page
4. Customer sees "Welcome [Company], [Motto]" page

```

### Implementation Ideas

```text
Example pipeline steps:
1. Receive purchase webhook
2. Extract customer data (company name, motto)
3. Generate personalized HTML page
4. Deploy/serve page at customer-specific URL
5. Send welcome email with link

Data structure ideas:
- Customer table: id, company_name, motto, created_at
- Page template: "Welcome {{company_name}}! {{motto}}"

```

---

*Good luck! We're excited to see your approach to solving this customer onboarding
pipeline challenge.*
