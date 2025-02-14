# Create an OpenSearch domain
resource "aws_opensearch_domain" "knowledgebase" {
    domain_name           = "knowledgebase"
    cluster_config {
        instance_type = "t3.small.elasticsearch"
        elasticsearch_version = "7.10"
    }

    ebs_options {
        ebs_enabled = true
        volume_size = 10
    }

    access_policies = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "es:ESHttpGet",
                "es:ESHttpHead",
                "es:ESHttpPost",
                "es:ESHttpPut",
                "es:ESHttpDelete"
            ],
            "Resource": "arn:aws:es:${var.region}:${var.account_id}:domain/${aws_opensearch_domain.knowledgebase.domain_name}/*"
        }
    ]
}
EOF
}

# Create an S3 bucket
resource "aws_s3_bucket" "knowledgebase_bucket" {
    bucket = "knowledgebase-bucket"
    acl    = "private"
}

# Create a data source to sync from S3 bucket
data "aws_s3_bucket_object" "knowledgebase_data" {
    bucket = aws_s3_bucket.knowledgebase_bucket.id
    key    = "knowledgebase-data.json"
}

# Perform the sync from S3 to OpenSearch
resource "aws_opensearch_domain_policy" "knowledgebase_sync" {
    domain_name = aws_opensearch_domain.knowledgebase.domain_name

    access_policies = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "es:ESHttpPut"
            ],
            "Resource": "arn:aws:es:${var.region}:${var.account_id}:domain/${aws_opensearch_domain.knowledgebase.domain_name}/*"
        }
    ]
}
EOF

    dynamic "source" {
        for_each = data.aws_s3_bucket_object.knowledgebase_data
        content {
            s3_bucket_name = aws_s3_bucket.knowledgebase_bucket.id
            s3_key         = source.value.key
            role_arn       = aws_iam_role.knowledgebase_sync_role.arn
        }
    }
}

# Create an IAM role for the sync
resource "aws_iam_role" "knowledgebase_sync_role" {
    name = "knowledgebase-sync-role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "es.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    tags = {
        Name = "knowledgebase-sync-role"
    }
}

# Attach the necessary policies to the sync role
resource "aws_iam_role_policy_attachment" "knowledgebase_sync_role_policy" {
    role       = aws_iam_role.knowledgebase_sync_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonESFullAccess"
}