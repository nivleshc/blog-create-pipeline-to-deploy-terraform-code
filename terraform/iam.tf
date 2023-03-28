data "aws_kms_alias" "codepipeline_artifacts_s3_bucket_kms_key" {
  name = "alias/${var.codepipeline_artifacts_s3_bucket_kms_key_alias}"
}

resource "aws_iam_role" "codebuild_service_role" {
  name = var.codebuild_service_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_service_role_policy" {
  role = aws_iam_role.codebuild_service_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AccessToAWSCloudWatchLogs",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:${local.region_name}:${local.account_id}:log-group:${var.codebuild_cloudwatch_logs_group_name}:*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Sid": "CodeBuildAccessToS3",
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.codepipeline_artifacts_s3_bucket.arn}",
        "${data.aws_s3_bucket.codepipeline_artifacts_s3_bucket.arn}/*"
      ]
    },
    {
      "Sid": "CodeBuildAccesstoKMSCMK",
      "Effect": "Allow",
      "Action": [
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ],
      "Resource": [
        "${aws_kms_key.codepipeline_kms_key.arn}"
      ]
    },
    {
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": [
              "autoscaling.amazonaws.com",
              "elasticloadbalancing.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "eks:*",
      "Resource": "*"
    },
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:*:${local.account_id}:parameter/aws/*",
        "arn:aws:ssm:*::parameter/aws/*"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "logs:PutRetentionPolicy"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:ListInstanceProfiles",
        "iam:AddRoleToInstanceProfile",
        "iam:ListInstanceProfilesForRole",
        "iam:PassRole",
        "iam:DetachRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:GetOpenIDConnectProvider",
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider",
        "iam:TagOpenIDConnectProvider",
        "iam:ListAttachedRolePolicies",
        "iam:TagRole",
        "iam:GetPolicy",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:ListPolicyVersions",
        "iam:ListRolePolicies"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Sid": "AccessToAmazonDynamoDB",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:${local.region_name}:${local.account_id}:table/${var.dynamodb_lock_table_name}"
    }        
  ]
}
POLICY
}

resource "aws_iam_role" "codepipeline_role" {
  name = var.codepipeline_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = var.codepipeline_role_policy_name
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodePipelineAccessToS3",
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.codepipeline_artifacts_s3_bucket.arn}",
        "${data.aws_s3_bucket.codepipeline_artifacts_s3_bucket.arn}/*"
      ]
    },
    {
      "Sid": "CodePipelineAccesstoKMSCMK",
      "Effect": "Allow",
      "Action": [
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ],
      "Resource": [
          "${aws_kms_key.codepipeline_kms_key.arn}"
        ]
    },
    {
      "Sid": "AccessToCodeCommitRepo",      
      "Effect": "Allow",
      "Resource": [
        "${aws_codecommit_repository.infra_repo.arn}"
      ],
      "Action": [
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:GitPull"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Sid" : "AccessToSNS",
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "aws_codepipeline_approver_policy" {
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "codepipeline:ListPipelines"
          ],
          "Resource": [
              "*"
          ]
      },
      {
            "Effect": "Allow",
            "Action": [
                "codepipeline:GetPipeline",
                "codepipeline:GetPipelineState",
                "codepipeline:GetPipelineExecution"
            ],
            "Resource": "${aws_codepipeline.pipeline.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codepipeline:PutApprovalResult"
            ],
            "Resource": "${aws_codepipeline.pipeline.arn}/INFRA_TF_CHANGE_APPROVAL/ApprovalAction"
        }
    ]
}
POLICY
}


resource "aws_iam_role" "cloudwatch_events_role" {
  name = var.cloudwatch_events_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_events_policy" {
  name = var.cloudwatch_events_role_policy_name
  role = aws_iam_role.cloudwatch_events_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchPermissionToStartCodePipelinePipeline",
      "Effect": "Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": [
        "${aws_codepipeline.pipeline.arn}"
      ]
    }
  ]
}
EOF
}