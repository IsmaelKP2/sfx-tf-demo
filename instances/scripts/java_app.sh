#! /bin/bash
# Version 2.0

JAVA_APP_URL=$1
INVOKE_URL=$2
ENV_PREFIX=$3

# echo $JAVA_APP_URL > /tmp/java_app_url # just for debugging
# echo $INVOKE_URL > /tmp/invoke_url # just for debugging
# echo $ENV_PREFIX > /tmp/env_prefix # just for debugging

sudo apt update 
git clone "$JAVA_APP_URL"

sed -i -e "s+REPLACEWITHRETAILORDER+$INVOKE_URL+g" /home/ubuntu/SplunkLambdaAPM/MobileShop/APM/src/main/java/com/sfx/JavaLambda/JavaLambdaController.java
sed -i -e "s+REPLACEWITHRETAILORDER+$INVOKE_URL+g" /home/ubuntu/SplunkLambdaAPM/MobileShop/Base/src/main/java/com/sfx/JavaLambda/JavaLambdaController.java

sed -i -e "s+REPLACE-Mobile-Web-Shop-APM+$ENV_PREFIX-Mobile-Web-Shop-APM+g" /home/ubuntu/SplunkLambdaAPM/MobileShop/APM/src/main/resources/application.properties
sed -i -e "s+REPLACE-Mobile-Web-Shop-Base+$ENV_PREFIX-Mobile-Web-Shop-Base+g" /home/ubuntu/SplunkLambdaAPM/MobileShop/Base/src/main/resources/application.properties

sudo apt install maven -y