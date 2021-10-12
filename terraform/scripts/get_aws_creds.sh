#!/bin/bash

aws_api_key=$(curl -s metadata.udf/cloudAccounts | jq -r '.cloudAccounts[].apiKey')
aws_api_secret=$(curl -s metadata.udf/cloudAccounts | jq -r '.cloudAccounts[].apiSecret')

#echo "aws_access_key_id=${aws_api_key}"
#echo "aws_secret_access_key=${aws_api_secret}"

sed -i "s|aws_access_key_id=.*|aws_access_key_id=$aws_api_key|" ~/.aws/credentials
sed -i "s|aws_secret_access_key=.*|aws_secret_access_key=$aws_api_secret|" ~/.aws/credentials
