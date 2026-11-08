# Objective 4 — Scalable Web Serving

## What are we solving?

We need to support the scaling of 10–100 customers and consider the growth of customer base going beyond 100 to even 1000 or 10000 customers during onboarding
new customer and at the same time serving existing customers with high availability and performance.

Also we need to make sure the resource usage is evenly distributed among all customers based on their stack size.  We do not want one customer holding 99 resources and 
99 customer only having 1 to share among them.

## Solution

In order to solve this problem, we will need to consider and ask the following questions:

- Is Kubernete cluster large enough to hold all customers?
- Can one customer use up all resources without a limit?
- As the number of customers grow, do we see performance degradation?
- Are we able to go beyond max customer set in this problem which is 10 - 100 customer?  Can we go 1000?  Can we go 10000?  Can we go even beyond?
- Are we able to scale down to optimize cost when there is no or low usage?

To answer the questions, we need to implement a scalable web serving solution and make sure we meet all the criterias.
Most of the solution is already done as part of the Infrastructure as code objective in the terraform project(Objective 9) such as 

- Setting auto-scaling policy based on the cpu and memory usage.
- Setting resource-quota per customer
- Made sure we are not redeploying existing customers when new customer onboards

There are multiple solutions to solve this problem and all these solutions are valid not alternative solutions.

### Solution 1 - Cluster Sizing and Autoscaler

Initial EKS cluster sizing should be done to roughly hold up to 100 customers which is the max customers set in the problem.
For the purpose of interview, we did not do a proper sizing and an assumption has been made.  The EKS resource creation at default sizing
is done here in the terraform project. [EKS](./../my-solution-infrastructure-as-code-objective9/terraform/resources/eks.tf)

Initially, we are setting the instance_type and the desired_size, node_min_size and node_max_size for each environment:
   #### Dev: instance_type = t3.small, desired_size = 2, min_size = 1 and max_size = 3
   Proper Sizing needs to be done, but we are assuming that t3.small is enough to support the dev environment.  Dev environment is to test the SaS product to make sure
   the product is functioning correctly.  So we are minimizing the cost by using the smallest size that is available which is suitable to hold one SaS product infrastructure. 

   #### Staging: instance_type = t3.medium, desired_size = 2, min_size = 2 and max_size = 5
   Staging environment is also a test environment but it should be close to production.  We should test the onboarding of multiple customers here and make sure the auto-scaling policy works here before we promote to production.  However, we will use smaller than production as the number of customers will be fixed per test purpose and will not exceed 10.
   We are assuming t3.medium will serve that purpose and we are setting min_size to be 2 and max_size to be 5.
   
   #### Production: instance_type = t3.large, desired_size = 3, min_size = 3 and max_size = 10
   Production environment is the live customer environment and auto-scaling at the cluster level needs to work.  And we also need to select the right instance type to 
   hold the initial max number of customers we set in the problem which is 100.  We are assuming t3.large would serve that purpose with node_min_size of 3 to max_size of 10.
   This setting can be easily changed as we monitor the onboarding of the new customers and the customer base grows.  We are assuming at min setting, it can serve 10 customer. 
   At max scale, we assume 100 customers can be served.  When customer base grows to 101, the configuration needs to be changed.  Proper sizingand trade-off analysis needs to be done to have a concrete set for the long term.  For example, if current customer base is 100, and we expect this to become 1000 in the next 10 years, we can revisit the sizing every year and update.  However, if we expect to become 1000 in the next one year then upsize it to cover it. 

These are passed in as variables so the value can be changed based on the proper sizing analysis.
For example, for dev, node sizes are overriden from this file: [sas-dev](./../my-solution-infrastructure-as-code-objective9/terraform/environments/dev/sas-dev.tf)

The EKS cluster node auto-scaling policy is set here: [cluster-autoscaler](./../my-solution-infrastructure-as-code-objective9/terraform/resources/cluster-autoscaler.tf) 

### Solution 2 - Kubernetes Pod Sizing and HPA

This is done at the customer pod level.  We want to serve each customer with high availability and consistent high performance.
When customer traffic increases, our product system must scale up or down to meet customer needs while optimizing the cost.
As each customer uses the sas product, we want to make sure we can handle the customer use traffic.  Autoscaling policy is set using 
cpu_usage and memory usage and when it goes beyond threshold at 70% CPU and 80% memory on requests, we would automatically spin up another pod to serve more traffic.  
And vice versa we scale down when cpu-usage and memory 5 minutes below target.

Customer pod sizing should be done properly based on the customer profile(e.g size of the customer etc.)
This is built here: [Pod sizing](./../my-solution-pipeline-orchestration-objective5/helm/tenant-template/values.yaml).
These are easily changed per customer.  But all pods are same size through out the environment.  Nodes size vary per environment.   

And the Horizontal Pod Autoscaling policy is setin the helm chart here: [HPA](./../my-solution-pipeline-orchestration-objective5/helm/tenant-template/templates/hpa.yaml)
Numbers in this project:
 - Minimum replicas: 2 per customer (for high availability — one pod can fail or be restarted without the site going down)
 - Maximum replicas: 5 per customer
 - Target: 70% CPU utilization and 80% Memory utilization.

How EKS cluster auto-scaling works with HPA, in order:
   1. Load rises → HPA adds pods, 2 → 5.
   2. If no node has room → new pods are Pending.
   3. Cluster Autoscaler sees Pending pods and raises the
      node group's desired size, up to max_size.
   4. A new node joins, Pending pods are scheduled.
   5. Load falls → HPA scales pods down to 2, after the 5-minute stabilization window.
   6. Nodes are underused for 10 minutes → Cluster Autoscaler drains them and removes them, down to min_size.
   Why this matters at 100 customers: 100 customers ×
   2 pods minimum = 200 pods minimum, plus HPA headroom to
   500 pods. Pod count alone does not scale the cluster —
   node capacity has to scale too, or the extra pods sit
   in Pending. That is what Cluster Autoscaler solves.

Cluster auto-scaling increases the number of nodes based on node capacity of adding pods.  Then there is the cluster sizing t3.medium, t3.small and so on. 
How do we solve the infinitely growing customers?  Do we monitor and come back and resize the cluster with autoscaling policy set at the node and pod level?  
What is the node capacity?  Is that differ per cluster sizing? 

### Solution 3 - Customer Resource Quota
We put a resource quota so that no customers can request certain cpu usage and memory usage and max scale pods. 

This is built here: [Resource Quota](./../my-solution-infrastructure-as-code-objective9/terraform/modules/customer/main.tf).
These are easily changed per customer.  Initially, we are setting request cpu and memory to be 2 and 2Gi with limits on are 4 and 4Gi and number of pods limited to 10
Again, these can be set based on customer profile.  And this is to prevent one customer dominating resource and it is the noisy-neighbour protection.
If one customer's site spikes, HPA can add pods for that customer up to its quota, but it cannot take CPU or memory from the other 99
customers' namespaces.

### Solution 4 - Routing per customer - Ingress
One host per customer, routed by the Ingress to that customer's service and only to pods in that customer's namespace. 
This is set here: [Ingress](./../my-solution-pipeline-orchestration-objective5/helm/tenant-template/templates/ingress.yaml) 
host = var.host and resource "kubernetes_service" "web". DNS for *.sas-product.com set in here: [route53](./../my-solution-infrastructure-as-code-objective9/terraform/resources/route53.tf) which is a hosted zone plus a wildcard record pointing at the ALB created by the AWS Load Balancer Controller. 

Ingress is the routing layer, not the scaling layer. It doesn't add pods — HPA and Cluster Autoscaler do that. What Ingress gives me is one entry point for 100 hosts, 
host-based isolation per customer, and a routing layer that follows the Service endpoints automatically, so when HPA adds a pod, traffic reaches it without any routing change. That's how scaling stays operational at 100 customers instead of becoming a routing problem.