import {
  to = aws_cloudfront_distribution.site
  id = "E1S67IML931NSV"
}

import {
  to = aws_cloudfront_function.redirect_to_www
  id = "RedirectToWWW"
}

import {
  to = aws_s3_bucket.site
  id = "www.zendcraft.net"
}

import {
  to = aws_s3_bucket_website_configuration.site
  id = "www.zendcraft.net"
}

import {
  to = aws_s3_bucket_policy.site
  id = "www.zendcraft.net"
}

import {
  to = aws_s3_bucket_public_access_block.site
  id = "www.zendcraft.net"
}

import {
  to = aws_s3_bucket.apex_redirect
  id = "zendcraft.net"
}

import {
  to = aws_s3_bucket_website_configuration.apex_redirect
  id = "zendcraft.net"
}

import {
  to = aws_instance.backend
  id = "i-0cf04dcdd635c4d73"
}

import {
  to = aws_iam_role.backend
  id = "EC2SSMReadOnly"
}

import {
  to = aws_iam_instance_profile.backend
  id = "EC2SSMReadOnly"
}

import {
  to = aws_iam_role_policy_attachment.backend_ssm_readonly
  id = "EC2SSMReadOnly/arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

import {
  to = aws_security_group.backend
  id = "sg-0002781b271121d9a"
}

import {
  to = aws_vpc_security_group_ingress_rule.http
  id = "sgr-0098be362113a2e33"
}

import {
  to = aws_vpc_security_group_ingress_rule.https
  id = "sgr-05d157b5c31bdee85"
}

import {
  to = aws_vpc_security_group_ingress_rule.ssh_anywhere
  id = "sgr-05632bf3a32a44a98"
}

import {
  to = aws_vpc_security_group_ingress_rule.ssh_home
  id = "sgr-006b7ba18bfe5b93e"
}

import {
  to = aws_vpc_security_group_ingress_rule.express_direct
  id = "sgr-0c7c7ab9d514a7cfc"
}

import {
  to = aws_vpc_security_group_egress_rule.all
  id = "sgr-0c026f099e4c03020"
}
