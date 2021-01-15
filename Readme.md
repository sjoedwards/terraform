# Terraform

Following [this link](https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785)

### Create Docker Registries

- terraform init
  `terraform init`

- terraform apply
  `terraform apply`

Go to Amazon ECR to ensure the repos are there

### Login to docker

Go into AWS -> ECR and click on the repo -> push commands, follow the login command

### Build image

`docker build -t sjoedwards-ecr-demo .`

### Tag image

```
docker tag sjoedwards-ecr-demo:latest 261905387697.dkr.ecr.eu-west-2.amazonaws.com/sjoedwards-ecr-demo:latest
```

### Push image

```
docker push 261905387697.dkr.ecr.eu-west-2.amazonaws.com/sjoedwards-ecr-demo:latest
```

Check ECR to ensure pushed successfully

### Configure AWS

- AWS configure

- terraform init
  `terraform init`

- terraform apply
  `terraform apply`

## Access Resource

On AWS -> Load Balancer -> DNS name

## Key links on AWS

- ECR to view containers
- ECS to view cluster
- VPC to view virtual private cluster
- EC2 -> Load balancer to view load balancing

## Destroy the cluster

`terraform destroy`
