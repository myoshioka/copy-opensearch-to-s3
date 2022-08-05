# Copy all indices of AWS OpenSearch to S3

## Description

- This will be a shell script for a case where there is an OpenSearch in VPC and you need to connect via ssh port forwarding.
- Get a list of indexes, dump the OpenSearch data for each index and upload to S3.
- Index name is assumed to be in [app-log-yyyy-MM-dd] format

## Requirement

- [elasticsearch-dump](https://github.com/elasticsearch-dump/elasticsearch-dump)
- [awscurl](https://github.com/okigan/awscurl)

## Usage

- Connect to OpenSearch with ssh port forwarding via a bastion server.

```bash
$ ssh -i ~/.ssh/[BASTION-SERVER-SECRET-KEY] ec2-user@[BASTION-SERVER-IP] -L 9200:[OPEN_SEARCH_HOST]:443
```

- Uses the access keys of IAM user with OpenSearch access permission.

```bash
$ S3_BUCKET_NAME=your-bucket_name \
AWS_ACCESS_KEY_ID=your-key-id \
AWS_SECRET_ACCESS_KEY=your-access-key \
./es-dump.sh
```

