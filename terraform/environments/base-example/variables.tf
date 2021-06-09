variable "aws_region" {
  default = "eu-west-1"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "private_subnet_ids" {
  description = "private subnet ids"
  type        = list(string)
}

variable "cloudflare_email" {
  description = "cloudflare email to acces your DNS"
}

variable "cloudflare_token" {
  description = "cloudflare token to acces your DNS"
}

variable "domain_name" {
  description = "domain"
}

variable "subdomain_name" {
  description = "subdomain"
  default     = "app-test"
}

variable "subdomain_name_backend" {
  description = "subdomain for backend/api gateway"
  default     = "api-test"
}

variable "frontend_s3_origin_id" {
  description = "s3 origin id of frontend bucket"
}

variable "frontennd_s3_origin_domain_name" {
  description = "s3 origin domain name of frontend bucket"
}

variable "s3_bucket_artifacts" {
  description = "s3 bucket where to upload SAM artifactes"
}
