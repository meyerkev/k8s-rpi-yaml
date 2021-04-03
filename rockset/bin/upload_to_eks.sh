cd $(dirname $0)
. vars.sh

# Go to root of rockset/
cd ..

ECR_REGISTRY=${ACCOUNT_ID?}.dkr.ecr.${REGION?}.amazonaws.com/${IMAGE?}

# Runs `docker login` to give us keys into AWS
$(aws ecr get-login --region ${REGION?} --no-include-email)

docker tag ${IMAGE?} ${ECR_REGISTRY?}
docker push ${ECR_REGISTRY?}

