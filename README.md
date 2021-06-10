# aws-serverless-go-blog-post

Sample repository for blog post about our expieriance using Terraform and SAM template

## terraform

Before you will be able to run terraform commands to deploy this example, you have to first provide values for some variables.

## Inputs

| Name                            | Description                                                                                                             | Type           | Default     | Required |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- | :------: |
| cloudflare_token                | The Cloudflare API key. This can also be specified with the CLOUDFLARE_API_KEY shell environment variable.              | `string`       | n/a         |   yes    |
| cloudflare_email                | The email associated with the account. This can also be specified with the CLOUDFLARE_EMAIL shell environment variable. | `string`       | n/a         |   yes    |
| domain_name                     | Primary certificate domain name                                                                                         | `string`       | n/a         |   yes    |
| aws_region                      | Aws region to ACM certificate                                                                                           | `string`       | `eu-west-1` |   yes    |
| subdomain_name                  | Subdomain that you will use for exposing frontend via Cloudflare                                                        | `string`       | `app-test`  |   yes    |
| subdomain_name_backend          | Subdomain that you will use for exposing api gateway via Cloudflare                                                     | `string`       | `api-test`  |   yes    |
| vpc_id                          | VPC ID of your VPC                                                                                                      | `string`       | n/a         |   yes    |
| private_subnet_ids              | Private subnet of your VPC                                                                                              | `list(string)` | n/a         |   yes    |
| frontend_s3_origin_id           | S3 origin id of frontend bucket                                                                                         | `string`       | n/a         |   yes    |
| frontennd_s3_origin_domain_name | S3 origin domain name of frontend bucket                                                                                | `string`       | n/a         |   yes    |
| private_s3_bucket_artifacts     | S3 bucket where to upload SAM artifactes                                                                                | `string`       | n/a         |   yes    |

To run a terraform plan:

```bash
make tf-plan
```

To run a terraform apply:

```bash
make tf-apply
```

To run a terraform destroy:

```bash
make tf-destroy
```

## Local testing

To run locally lambda function with api gateway:

```bash
make be-up
```

Lambda function will be started on port 3003 and running simple curl commands you'll get appropiate response from lambda function.

```bash
curl http://localhost:3003/user
or
curl -X POST http://localhost:3003/user
or
curl http://localhost:3003/organization
or
curl -X PUT http://localhost:3003/organization
```
