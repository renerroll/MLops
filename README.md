
# MLops — VPC + EKS (Lesson 5-6)

Overview
- Module-based Terraform structure: `vpc/` and `eks/`.
- Uses official modules: `terraform-aws-modules/vpc/aws` and `terraform-aws-modules/eks/aws`.
- After `terraform apply` the cluster should be accessible with `kubectl`.

Required tools
- terraform >= 1.0
- awscli (configured profile with permissions to create VPC/EKS)
- kubectl
- jq (optional)

Quick start
1. Set AWS profile (if needed):

```bash
export AWS_PROFILE=default
```

2. Format and validate Terraform configs:

```bash
terraform fmt -recursive
terraform validate
```

3. Initialize (upgrade provider lockfile if needed):

```bash
terraform init -upgrade
```

4. Plan and apply (if you have `terraform.tfvars` it will be loaded automatically):

```bash
terraform plan -var-file="terraform.tfvars" -out=tfplan
terraform apply "tfplan"
# or quick: terraform apply -var-file="terraform.tfvars" -auto-approve
```

Key outputs
- `eks_cluster_name` — cluster name
- `kubectl_config_command` — command to update kubeconfig
- `vpc_id`, `public_subnets`, `private_subnets`

Acceptance checklist

1) VPC created with official module

Check:
```bash
terraform output vpc_id
terraform output public_subnets
terraform output private_subnets
```

2) EKS with two node groups 

Check:
```bash
CLUSTER=$(terraform output -raw eks_cluster_name)
aws eks list-nodegroups --cluster-name "$CLUSTER" --region us-east-1 --profile $AWS_PROFILE
```
Expect: two nodegroups (for example `cpu_nodes-...` and `gpu_nodes-...`).

3) Working Terraform configuration (init + apply without errors) — 20 points

Check: `terraform init` and `terraform apply` run without errors.

4) Cluster accessible via kubectl

After apply update kubeconfig and check nodes:
```bash
aws eks --region us-east-1 update-kubeconfig --name "$CLUSTER" --profile $AWS_PROFILE
kubectl get nodes
kubectl get pods -A
```

If `kubectl` reports `You must be logged in to the server` or `the server has asked for the client to provide credentials`:
- Verify `aws sts get-caller-identity --profile $AWS_PROFILE` returns your ARN.
- Ensure your ARN is present in the `aws-auth` ConfigMap with `system:masters` group.

Add admin via Terraform (recommended):
Add a user mapping to the EKS module call, for example:

```hcl
map_users = [
  {
    userarn  = "arn:aws:iam::111924087894:user/your-user"
    username = "admin-user"
    groups   = ["system:masters"]
  }
]
```

After `terraform apply` the `aws-auth` will be updated and your user will be able to run `kubectl`.

Alternative (quick manual option):
- If another IAM admin exists, they can export and update the `aws-auth` ConfigMap:

```bash
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml
# add your userarn or rolearn to mapUsers/mapRoles in aws-auth.yaml
kubectl apply -f aws-auth.yaml -n kube-system
```

5) README.md present — 10 points

This file documents steps to run, verify and troubleshoot the project.

Helpful diagnostic commands
- Describe cluster:
```bash
aws eks describe-cluster --name "$CLUSTER" --region us-east-1 --profile $AWS_PROFILE --output yaml
```
- Generate token manually:
```bash
aws eks get-token --cluster-name "$CLUSTER" --region us-east-1 --profile $AWS_PROFILE
```
- Check nodegroup status:
```bash
aws eks describe-nodegroup --cluster-name "$CLUSTER" --nodegroup-name <NODEGROUP_NAME> --region us-east-1 --profile $AWS_PROFILE
```
- Check CloudFormation events (nodegroup stack):
```bash
aws cloudformation describe-stack-events --stack-name <stack-name> --region us-east-1 --profile $AWS_PROFILE --max-items 50
```

Destroying infrastructure
```bash
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

Git and preparing submission
```bash
git checkout -b lesson-5-6
git add .
git commit -m "lesson-5-6: add VPC + EKS infra"
git push --set-upstream origin lesson-5-6

# Create an archive for submission
cd ..
zip -r mlops-lesson-5-6.zip MLops
```

Security notes
- Do not commit `*.tfvars` containing secrets.
- `.gitignore` excludes local state and editor files.
- For production use a remote backend (S3 + DynamoDB).
