data "aws_acm_certificate" "site" {
  provider    = aws.us_east_1
  domain      = "zendcraft.net"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

locals {
  s3_origin_id = "zendcraft.net.s3.amazonaws.com-mccu8k6t8r9"
}

resource "aws_cloudfront_distribution" "site" {
  aliases             = ["www.zendcraft.net", "zendcraft.net"]
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  tags = {
    Name = "zendcraft-distribution"
  }

  origin {
    origin_id   = local.s3_origin_id
    domain_name = aws_s3_bucket_website_configuration.site.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.site.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

# Leftover from an earlier attempt; redirects the wrong way and is attached to nothing.
resource "aws_cloudfront_function" "redirect_to_www" {
  name    = "RedirectToWWW"
  runtime = "cloudfront-js-2.0"
  publish = false
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var headers = request.headers;

      if (headers.host && headers.host.value === 'zendcraft.net') {
        return {
          statusCode: 301,
          statusDescription: 'Moved Permanently',
          headers: {
            location: { value: 'https://www.zendcraft.net' }
          }
        };
      }

      return request;
    }
  EOT
}
