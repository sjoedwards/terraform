# Terraform

Following [this link](https://medium.com/avmconsulting-blog/how-to-deploy-a-dockerised-node-js-application-on-aws-ecs-with-terraform-3e6bceb48785)

For addition of NGNIX following [this link](https://techsparx.com/nodejs/docker/simple-node-deploy-ecs-terraform.html)

### Create Docker Registries

`terraform apply -target=aws_ecr_repository.ecr_repo_app`

`terraform plan -target=aws_ecr_repository.ecr_repo_app`

Go to Amazon ECR to ensure the repos are there

### Login to docker

Go into AWS -> ECR and click on the repo -> push commands, follow the login command for both

### Build App image

`cd app`
`docker build -t sjoedwards-ecr-demo .`

### Tag App image

```
docker tag sjoedwards-ecr-demo:latest 261905387697.dkr.ecr.eu-west-2.amazonaws.com/sjoedwards-ecr-demo:latest
```

### Push App image

```
docker push 261905387697.dkr.ecr.eu-west-2.amazonaws.com/sjoedwards-ecr-demo:latest
```

### Build nginx image

`cd nginx`
`docker build -t sjoedwards-ecr-nginx .`

### Tag nginx image

```
docker tag sjoedwards-ecr-nginx:latest 261905387697.dkr.ecr.eu-west-2.amazonaws.com/sjoedwards-ecr-nginx:latest
```

### Push nginx image

```
docker push 261905387697.dkr.ecr.eu-west-2.amazonaws.com/sjoedwards-ecr-nginx:latest
```

Check ECR to ensure pushed successfully

### Configure AWS

- AWS configure

- terraform init
  `terraform init`

- terraform plan
  `terraform plan`

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
