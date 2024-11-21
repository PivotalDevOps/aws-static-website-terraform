# Info

The Terraform template completes the following tasksj
* Creates Route53 hosted zone
* Creates SSL certificate
* Creates CloudFront
* Creates S3 bucket
* Uploads ./html/index.html to the S3 bucket


# Deploy static site

* Put you web content in `html` folder

```bash
DOMAIN_NAME=example.com

terraform apply -var domain="${DOMAIN_NAME}"
```

# Undeploy static site

```bash
DOMAIN_NAME=example.com

terraform destroy -var domain="${DOAMIN_NAME}"
```
