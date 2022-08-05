#!/bin/sh
set -eu

start_index=${1:-undefined}
host=${2:-localhost}

if [ ${AWS_ACCESS_KEY_ID-undefined} = "undefined" ] ||
   [ ${AWS_SECRET_ACCESS_KEY-undefined} = "undefined" ] ||
   [ ${S3_BUCKET_NAME-undefined} = "undefined" ]; then

    echo 'Set environment variable and try again.' >&2
    exit -1
fi

export NODE_TLS_REJECT_UNAUTHORIZED=0
LOCAL_PORT=9200

indices=$(
    awscurl -k \
            --service es \
            --region ap-northeast-1 \
            --access_key ${AWS_ACCESS_KEY_ID}  \
            --secret_key ${AWS_SECRET_ACCESS_KEY} \
            --request GET \
            --header "host: amazonaws.com" \
            "https://${host}:${LOCAL_PORT}/_cat/indices?h=i&s=i"
       )

echo $indices

for index in $indices
do
    # skip index dump
    if [ $start_index != "undefined" ]; then
        if [ $index = $start_index ]; then
            start_index='undefined'
        else
            continue
        fi
    fi

    if [[ $index == "app-log-"* ]]
    then
        echo "----------"
        echo "Dump index ---> $index"
        echo ""

        index_array=(${index//-/ })

        npx elasticdump \
            --input https://${host}:${LOCAL_PORT}/${index} \
            --output "s3://${S3_BUCKET_NAME}/${index_array[2]}/${index_array[3]}/${index_array[4]}/es_dump_${index}.gz" \
            --type=data \
            --awsAccessKeyId=${AWS_ACCESS_KEY_ID} \
            --awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
            --awsService=es \
            --awsRegion=ap-northeast-1 \
            --sourceOnly=true \
            --awsUrlRegex='^https?:\/\/${host}.*$' \
            --s3AccessKeyId=${AWS_ACCESS_KEY_ID} \
            --s3SecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
            --s3Compress=true \
           --limit=500
    fi
done
