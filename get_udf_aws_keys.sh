#!/bin/bash

curl -s 10.1.1.254/cloudAccounts > cloudAccounts.json

export AWS_ACCESS_KEY_ID=$(jq -r '.cloudAccounts[].apiKey' < ./cloudAccounts.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.cloudAccounts[].apiSecret' < ./cloudAccounts.json)
export AWS_ACCCOUNT_ID=$(jq -r '.cloudAccounts[].accountId' < ./cloudAccounts.json)
export AWS_CONSOLE_LINK=$(printf https://${AWS_ACCCOUNT_ID}.signin.aws.amazon.com/console)
export AWS_USER=$( jq -r '.cloudAccounts[].consoleUsername' < ./cloudAccounts.json)
export AWS_PASSWORD="$(jq -r '.cloudAccounts[].consolePassword' < ./cloudAccounts.json)"

if [ ! -d ~/.aws ]; then
    mkdir ~/.aws
    envsubst < ./config.template > ~/.aws/config
else
    envsubst < ./config.template > ~/.aws/config
fi

printf "AWS Access Key ID: \n%s\n\n" ${AWS_ACCESS_KEY_ID}
printf "AWS Secret key: \n%s\n\n" ${AWS_SECRET_ACCESS_KEY}
printf "AWS Console URL:\n%s\n\n" ${AWS_CONSOLE_LINK}
printf "AWS Console Username:\n%s\n\n" ${AWS_USER}
printf "AWS Console Password:\n%s\n\n" ${AWS_PASSWORD}
