#! /usr/bin/env bash

ECS_CLUSTERS="$1"
APP_NAME="$2"
AWS_REGION="$3"
IFS=';' read -ra C <<< "$ECS_CLUSTERS"
for cluster in "${C[@]}"; do
    aws ecs update-service --service $(APP_NAME) --cluster $(ECS_CLUSTER) --region $(AWS_REGION) --task-definition $(APP_NAME)
    echo "Updated service in cluster: $cluster"
done
