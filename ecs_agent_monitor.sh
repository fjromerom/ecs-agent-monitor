#!/bin/bash

INSTANCEID=`curl --silent http://169.254.169.254/latest/meta-data/instance-id/`
AZ=`curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$AZ\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
URL="http://localhost:51678"
HTTP_RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null $URL)

if [ $HTTP_RESPONSE != 200 ]; then

aws cloudwatch put-metric-data --metric-name ECSAgentStatus --namespace ECSAgent --dimensions InstanceID=$INSTANCEID --value 1 --unit Count --region $REGION

else

aws cloudwatch put-metric-data --metric-name ECSAgentStatus --namespace ECSAgent --dimensions InstanceID=$INSTANCEID --value 0 --unit Count --region $REGION

fi
