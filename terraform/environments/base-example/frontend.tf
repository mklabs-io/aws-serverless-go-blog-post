provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_acm_certificate" "frontend" {
  provider          = aws.virginia
  domain_name       = "${var.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

resource "cloudflare_record" "validation_domain" {
  name       = aws_acm_certificate.frontend.domain_validation_options[0]["resource_record_name"]
  value      = trimsuffix(aws_acm_certificate.frontend.domain_validation_options[0]["resource_record_value"], ".")
  type       = aws_acm_certificate.frontend.domain_validation_options[0]["resource_record_type"]
  zone_id    = lookup(data.cloudflare_zones.frontend.zones[0], "id")
  depends_on = [aws_acm_certificate.frontend]
}

resource "aws_acm_certificate_validation" "frontend" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.frontend.arn
  validation_record_fqdns = cloudflare_record.validation_domain.*.hostname
}

resource "aws_cloudfront_distribution" "frontend" {
  enabled         = true
  aliases         = ["${var.subdomain_name}.${var.domain_name}"]
  is_ipv6_enabled = true
  // cheapest: https://github.com/laurilehmijoki/s3_website/issues/150
  price_class = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.frontend_s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = var.frontennd_s3_origin_domain_name
    origin_id   = var.frontend_s3_origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only" // setting defined after terraform import. can try with https-only
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.frontend.certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }
}

resource "cloudflare_record" "frontend_service" {
  name    = "${var.subdomain_name}.${var.domain_name}"
  value   = aws_cloudfront_distribution.frontend.domain_name
  type    = "CNAME"
  proxied = true
  zone_id = lookup(data.cloudflare_zones.default.zones[0], "id")
}
