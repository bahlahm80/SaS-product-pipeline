# Objective 9 - Infrastructure as Code
This readme will cover the implementation details.

## What are we solving?
Each customer will need to have its own infrastructure based on the customer profile.  And we will need a secured, high availibility 
and high performance infrastructure to serve all customers.

## Solution

In order to solve this problem, we will need to consider and ask the following questions:

- What resources do we need to create at the infrastructure level?
- How do we make sure customers can access our SaS product without worring about security?
- How do we make sure we have infrastructure that can server customers at any traffic level with high availability?

To solve this problem, we are going to use terraform which allows you to create infrastructure as a code at ease.
We will assume we are deploying to aws for the purpose of interview and my expertise being in aws.

### EKS
This is the most important resource that we need to create as this is the backbone for managing kubernetes pods that serves
customers.  The resource must be created with right sizing requirement as well as right resource quota and auto-scaling policy
to serve customers at high availability and high performance.

This is configured here: [EKS](./terraform/resources/eks.tf)

### ECR
Another important resource we need to create is ECR which is where we keep our SaS product artifact that we want to deploy.
Kubernetes pod will be empty without artifact that needs to be deployed on to the tenant to serve customers. 

This is configured here: [ECR](./terraform/resources/ecr.tf)

### IAM
This resource is created in order to give authentications and permissions to run tasks that is required to run deployment through
CI/CD pipeline.  Without this resource, deployment will fail as the resources are secured as well as source code which resides in 
GitHub repository.  We set IAM roles to access github and aws resources so that the deployment runs smoothly and successfully. 

This is configured here: [IAM](./terraform/resources/iam.tf)

### NETWORK and Route53

This is configured here: [Network](./terraform/resources/network.tf) and [Route53](./terraform/resources/route53.tf)

### Security Group

This is configured here: [Security Groups](./terraform/resources/security.tf)

### Variables for configuring resources specifically EKS
Since we have infrastructures set for dev, staging and production, we need variables to create different infrastructures that meed each environment. 
For example, dev is a testing environment so we can go a little light on the sizing where as production is real live customer environment so 
we may need to upsize it.  Variables can be defined at runtime and creates infrastructures using those values per environment. 

This is configured here: [Variables](./terraform/variables.tf) and [Outputs](./terraform/outputs.tf)


### Environments
Each environment infrastructure can be created by running the terraform command. 

For Dev environment, run following:

``` cd terraform/environments/dev
    terraform init
    terraform plan
    terraform apply
```

For Staging, run same commands but from staging folder and same for production from production folder. 