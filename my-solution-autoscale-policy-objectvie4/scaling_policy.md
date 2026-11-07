# Objective 4 — Scalable Web Serving

## Problem Statement

Allow each customer to host their own website, for 10–100 customers, automated and reliable.  Also consider future customer growth up to 1000 customers. 

## Solution

We will need to consider and ask the following questions:

- Is Kubernete cluster large enough to hold all customers?
- Can one customer use up all resources without a limit?
- As the number of customers grow, do we see performance degradation?
- Are we able to go beyond max customer set in this problem which is 10 - 100 customer?
- Are we able to scale down to optimize cost when there is no or low usage?

To answer the questions, we need to implement a scalable web serving solution and make sure we meet all the criterias.
Most of the solution is already done as part of the Infrastructure as code objective in the terraform project(Objective 9) such as 

- Setting auto-scaling policy based on the cpu and memory usage.
- Setting resource-quota per customer
- Made sure we are not redeploying existing customers when new customer onboards



### Cluster Sizing and Autoscaler

This is at the global level setting the kubernetes cluster with right sizing to determine make sure we can host 100 customers. The sizing should be done to hold up to 1000 customers in case we need to go beyond 100 but the sizing can be updated so we can start with 100 customers and we  can upsize it as we get close to 100 customers and also from monitoring the traffic as we onboard customers.

What is built: EKS managed node groups, with per-environment minimum / maximum / desired size, in resources/eks.tf — module "eks", using terraform-aws-modules/eks/aws. The node group scalesEx within its min/max as pods are scheduled. What is NOT built: Cluster Autoscaler as a Terraform resource. It is a discussion point, not a built resource in this project: as the tenant count grows from 10 to 100, node capacity has to grow too, and Cluster Autoscaler is how that happens in EKS. I do not claim it is installed here.

### Pod Sizing - Vertical Scaling - Should be fixed based on the performance tests

This is done at the customer level.  Pods running on the Clusters per customer will have different requirements.  We want to optimize the performance for each customer
and scale so that it serves all customers onboarding happily.

Where it is built:
modules/customer/main.tf — in the kubernetes_deployment
resource, in both the nginx and backend containers.
Per-environment sizing: the node group and container
sizing are variables, not hardcoded values, so dev can be
cheap and production can be properly sized. The variables
are node_instance_types, node_min_size, node_max_size,
node_desired_size, and container_cpu_request /
container_memory_request / container_cpu_limit /
container_memory_limit, declared in
terraform/variables.tf and terraform/resources/variables.tf,
passed through terraform/main.tf, and set in each
environment file. The defaults are the small values above
(t3.small nodes, minimum 1, maximum 3, desired 2).
Production should override them with larger instance types
and higher minimums — that override is supported, it is not
yet set to a load-tested production number, and I do not
claim it was load-tested for SAS.
Where it came from: at Workday, Orchy v1 was first sized
at t3.medium and raised to m3.large after a 3-user load
test showed it needed more headroom. That is the same
reasoning here: start small, measure, raise the limit when
the load test says so — do not guess a large size up front.

### Pod auto-scaling policy - Horizontal Pod Autoscaler

This is at customer level.  As each customer uses the sas product, we want to make sure we can handle the customer use traffic.  When traffic increases and cpu_usage and memory usage goes beyond threshold at 70% for both, we would automatically spin up another pod to serve more traffic.  And vice versa we scale down when cpu-usage and memroy usage goes below 20% to save resources and minimize the cost.

Numbers in this project:
Minimum replicas: 2 per customer (for high availability —
  one pod can fail or be restarted without the site going down)
Maximum replicas: 5 per customer
Target: 70% CPU utilization
Where it is built:
my-solution-infrastructure-as-code-objective9/terraform/modules/customer/main.tf
— resource "kubernetes_horizontal_pod_autoscaler_v2" "web",
CPU metric only.
Where it came from: this is my AWS autoscaling experience
from Orchy v1, translated to Kubernetes. Orchy v1 ran on ECS
with a load balancer, minimum 3 containers, autoscaling to a
maximum of 10 on CPU / memory. I am not claiming prior
Kubernetes HPA experience — I am claiming the autoscaling
pattern, and applying it in Kubernetes for the first time here.

### Resource Quota per customer

We set this resource quota so that not one customer hogs over the resources. 

Where it is built:
modules/customer/main.tf —
resource "kubernetes_resource_quota" "this".
This is the noisy-neighbour protection. If one customer's
site spikes, HPA can add pods for that customer up to its
quota, but it cannot take CPU or memory from the other 99
customers' namespaces.

### Routing per customer - Ingress

What: one host per customer, routed by the Ingress to
that customer's Service, and only to pods in that customer's
namespace.
Example: test-company.sas-product.com → Service
customer-test-company-web → pods in namespace customer-test-company.
Where it is built:
modules/customer/main.tf —
resource "kubernetes_ingress_v1" "web", with
host = var.host, and resource "kubernetes_service" "web".
DNS for *.sas-product.com is in Objective 9:
resources/route53.tf — a hosted zone plus a wildcard
record pointing at the ALB created by the AWS Load Balancer
Controller.

# REVIEW these later

How a new customer gets the software
This is Objective 1 (Input Management) and Objective 2
(Data Deployment) working with Objectives 5 and 9, not
Objective 4 alone:
A customer completes a purchase. The purchase system sends
   a customer-purchased webhook / repository_dispatch
   event with { company_id, company_name, motto }.
The onboarding workflow validates the input, HTML-escapes
   the name and motto, and checks idempotency on
   company_id — already onboarded means return the
   existing URL, do not redeploy.
The workflow pulls the prod-approved image from the
   production ECR. It never rebuilds the image on purchase.
   The image is shared; only the ConfigMap data is
   per-customer.
Terraform applies from the production environment folder,
   with the new customer added to the customers map.
   for_each creates only that customer's namespace,
   ConfigMap, Deployment, Service, Ingress, and HPA.
   The other customers are already in state and unchanged.
A smoke check hits https://.sas-product.com,
   expects 200, and checks the page contains the company
   name and motto. Then the URL is reported to the customer.
What I deliberately did not build
No service mesh. Not needed for 10–100 welcome pages,
  and I do not claim it.
No custom-metrics HPA. HPA here is CPU only.
  Memory is a metric in the Deployment sizing, not in the
  HPA target. Custom metrics (requests per second, queue
  depth) are a next step, not built.
No Vertical Pod Autoscaler (VPA). HPA scales pod
  count. It does not resize pods. VPA would be a separate
  decision, with its own restart cost.
No per-customer VPC. Multitenancy here is namespace
  isolation, not a VPC per customer. One VPC, 100 namespaces.
No load-tested production numbers for SAS. The HPA
  target (70%), the min/max (2/5), and the requests/limits
  above are reasoned starting points from the Orchy
  translation, not SAS load-test results. A load test would
  be the next step before production, exactly as it was
  at Workday.
How to test it (kind drill, Nov 7–8)
This is not yet run — it is the drill to do before the
interview, in kind, not in AWS:
Create 3 example customers in kind.
Add a 4th customer with no workflow change — one entry
   in the customers map only.
Bump the version for one customer only, and deploy
   only that customer.
Roll back one customer only, without touching the others.
Load one customer's site and watch HPA scale its
   Deployment from 2 toward 5 pods, and scale back down.
If those five can be done fluently, Objective 4 is
demonstrated, not just documented.