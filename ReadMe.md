# SaS Interview Project

This repository contains the solutions to 3 objectives shown in the [10 Key Objectives to Consider](practical-devops-pipeline.md#10-key-objectives-to-consider):

- Objective 4 - Scalable Web Serving
- Objective 5 - Pipeline Orchestration
- Objective 9 - Infrastructure as Code

## 1. Problem we are solving

### Goal

We want to build a SaS product purchase end to end system.  When customer purchases our SaaS product, it will automatically deliver the product to the customer
and welcome page will be shown to the customer.  A personalized welcome page should include:

- Customer's Company Name
- Customer's Company Motto
- A "Welcome to SaS" message

We need to handle onboarding for 10 - 100 customers efficiently and possibly more in the future.
Pipeline should be automated and reliable. 
Solution should accomodate customer-specific data. 
And we need to consider how this scales as the customer base grows over time.

## 2. Choosing the 3 Objectives

Here is the general end to end happy path flow:

1. Customer clicks the purchase button from the SaaS product website.
2. Purchase system stores customer information to the database with unique customer_id
3. Purchase system generates a payload and triggers the CI/CD pipeline.
4. SaaS product infrastructure gets created.
5. SaaS product artifact gets deployed to the infrastructure.
6. Customer is taken to the personalized welcome page.

In order to solve the problem, we need to hit all 10 key objectives to consider.  For the purpose of the interview, the instruction stated to select 2 - 3 objectives.
I have selected key objectives based on the following criteria:

- Objectives that I think are top 3 priority in setting the foundation to solve the problem
- Where I have most knowledge and experience in my 20+ years career

As stated above, three objectives that I chose in the order of priority are:

- Objective 9 - Infrastructure as Code
- Objective 5 - Pipeline Orchestration
- Objective 4 - Scalable Web Serving.



## 3. General Approach on each objective

Details on the implementation, decisions, future improvements and what's not implemented are shown on the ReadMe.md file of each objective solution folders. 
This section will only explain the general approach on how to solve the problem.

### Objective 9: Infrastructure as Code (IaC)

We are using Terraform to declaratively manage Kubernetes namespaces, ingress controllers, RBAC, and tenant configurations across three isolated environments (dev, staging, and prod).
We assume we are deploying to AWS as I am mosst familiar with AWS environment and we assume each of these environments are seperate AWS accounts.
Resources are selected to meet the standard web serving architecture for this product. Following resources are created:

- EKS(Elastic Kubernetes Service)
- ECR(Elastic Container Registry)
- ALB(Application Load Balancer)
- IAM policies, documents
- SSM(AWS System parameter)
- Route53
- VPC(Virtual Private Cloud)
- Security Groups

More details are found in [Objective 9: Infrastructure as Code](./my-solution-infrastructure-as-code-objective9/ReadMe.md)

### Objective 5: Pipeline Orchestration

I am more familiar with Jenkins but wanted to learn about GitHub actions and since SaS uses GitHub actions, thought it would be a nice opportunity to use it here. 
The pipeline implements a 4-tier CI/CD promotion flow using GitHub Actions.  4 Tiers are PR-validation, dev, staging and production.  It leverages custom composite 
actions (./actions/build-artifact, ./actions/pull-artifact and ./actions/run-system-test) to execute critical steps in the pipeline in an isolated steps.
We are assuming artifactory is used to store the SaS product image.  Also we ensure integrated system tests pass before promoting subsequent deployment environments.
For production deployment, additional human approval gate has been set in place. 

Helm Chart is defined with customer specific information for deployment in configMap, deployment strategy, horizonal auto scaling policy, ingress rules and service endpoint.

More details are found in [Objective 5: CI/CD Pipeline Orchestration](./my-solution-pipeline-orchestration-objective5/ReadMe.md)

### Objective 4: Scalable Web Serving

For scalable solution, we've put in the following auto-scaling policy at different levels

- Autoscaling policy at the EKS cluster level 
- Autoscaling policy at the customer pod level (HPA)
- Ingress controller
- Configures tenant-specific ConfigMaps to inject personalized data into lightweight Nginx container instances. 
- Namespace isolation per customer

More details are found in [Objective 4: Scalable Web Serving](./my-solution-autoscale-policy-objective4/ReadMe.md)