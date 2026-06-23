resource "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-eks-cluster-role"
  assume_role_policy = jsonencode(
    {
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    }
  )

}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    role = aws_iam_role.eks_cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  
}

resource "aws_iam_role" "eks_node" {
  name = "${var.environment}-eks-node-role"
  assume_role_policy = jsonencode(
    {
        Version = "2012-10-17"
        Statement = [
           {
            
            Effect = "Allow"

            Principal = {
                Service = "ec2.amazonaws.com"
            }

            Action = "sts:AssumeRole"

           }

        ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
    role = aws_iam_role.eks_node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull_policy" {
  role = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
    role = aws_iam_role.eks_node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  
}

data "tls_certificate" "eks" {
    url = var.oidc_issuer_url  
}

resource "aws_iam_openid_connect_provider" "eks" {
    url = var.oidc_issuer_url
    client_id_list = [
        "sts.amazonaws.com"
    ]
  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}

data "aws_iam_policy_document" "alb_controller_assume_role" {
    statement {
      effect = "Allow"
      actions = [
        "sts:AssumeRoleWithWebIdentity"
      ]
      principals {
        type = "Federated"
        identifiers = [
            aws_iam_openid_connect_provider.eks.arn
        ]
      }
     condition {
       test = "StringEquals"
       variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
       values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
       ]
     }
    condition {
      test = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }


    }
  
}

resource "aws_iam_role" "alb_controller" {
    name = "${var.environment}-alb-controller-role"
    assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json
  
}

resource "aws_iam_policy" "alb_controller" {
    name = "${var.environment}-alb-controller-policy"
    policy = file("${path.module}/alb-controller-policy.json")  
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
    policy_arn = aws_iam_policy.alb_controller.arn
    role = aws_iam_role.alb_controller.name
}

data "aws_iam_policy_document" "karpenter_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    
    condition {
      test = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"
      values = ["system:serviceaccount:karpenter:karpenter"]
    }
    condition {
      test = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"
      values = ["sts.amazonaws.com"]
    }
   
  }
  
}


resource "aws_iam_role" "karpenter" {
  name = "${var.environment}-karpenter-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

resource "aws_iam_policy" "karpenter_controller" {
  name = "${var.environment}-karpenter-policy"
  policy = file("${path.module}/karpenter-controller-policy.json")
  
}

resource "aws_iam_role_policy_attachment" "karpenter" {
  role = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "aws_iam_role" "karpenter_node" {
  name = "${var.environment}-karpenter-node-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }

          Action = "sts:AssumeRole"
        }
      ]


    }
  )
  
}

resource "aws_iam_role_policy_attachment" "karpenter_worker" { 
    role = aws_iam_role.karpenter_node.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    
}

resource "aws_iam_role_policy_attachment" "karpenter_ecr" {
  role = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_cni" {
  role = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  
  
}

resource "aws_iam_role_policy_attachment" "karpenter_SSM" {
  role = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"  
  
}

data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:external-dns:external-dns"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(var.oidc_issuer_url, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  name = "${var.environment}-external-dns-role"

  assume_role_policy =
    data.aws_iam_policy_document.external_dns_assume_role.json
}

resource "aws_iam_policy" "external_dns" {
  name = "${var.environment}-external-dns-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "route53:ChangeResourceRecordSets"
        ]

        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}