#!/bin/bash
set -e

# Deploy via AWS CodeDeploy
# Triggers a deployment to the CodeDeploy deployment group

DEPLOYMENT_FILE="deployment-${GITHUB_SHA::8}.tar.gz"
AWS_REGION=${AWS_REGION:-us-east-1}
S3_BUCKET=${S3_BUCKET:?S3_BUCKET required}
CODEDEPLOY_APP=${CODEDEPLOY_APP:?CODEDEPLOY_APP required}
CODEDEPLOY_GROUP=${CODEDEPLOY_GROUP:?CODEDEPLOY_GROUP required}
PROJECT_NAME=${PROJECT_NAME:-trushot}
ENVIRONMENT=${ENVIRONMENT:-prod}

echo "=========================================="
echo "Deploying via AWS CodeDeploy"
echo "Application: $CODEDEPLOY_APP"
echo "Deployment Group: $CODEDEPLOY_GROUP"
echo "Deployment file: $DEPLOYMENT_FILE"
echo "S3 Location: s3://$S3_BUCKET/deployments/$DEPLOYMENT_FILE"
echo "=========================================="

# Create deployment
echo "Creating CodeDeploy deployment..."
DEPLOYMENT_ID=$(aws deploy create-deployment \
  --application-name "$CODEDEPLOY_APP" \
  --deployment-group-name "$CODEDEPLOY_GROUP" \
  --s3-location bucket="$S3_BUCKET",key="deployments/$DEPLOYMENT_FILE",bundleType=tgz \
  --deployment-config-name CodeDeployDefault.HalfAtATime \
  --description "Deployment from GitHub Actions - Commit ${GITHUB_SHA::8}" \
  --region "$AWS_REGION" \
  --query 'deploymentId' \
  --output text)

if [ -z "$DEPLOYMENT_ID" ]; then
  echo "❌ Failed to create deployment"
  exit 1
fi

echo "✅ Deployment created: $DEPLOYMENT_ID"
echo ""

# Wait for deployment to complete
echo "Waiting for deployment to complete..."
echo "You can monitor the deployment at:"
echo "https://${AWS_REGION}.console.aws.amazon.com/codesuite/codedeploy/deployments/${DEPLOYMENT_ID}"
echo ""

# Poll deployment status
MAX_WAIT_TIME=1800  # 30 minutes
SLEEP_TIME=15
ELAPSED_TIME=0

while [ $ELAPSED_TIME -lt $MAX_WAIT_TIME ]; do
  STATUS=$(aws deploy get-deployment \
    --deployment-id "$DEPLOYMENT_ID" \
    --region "$AWS_REGION" \
    --query 'deploymentInfo.status' \
    --output text)

  case "$STATUS" in
    "Succeeded")
      echo ""
      echo "=========================================="
      echo "✅ Deployment successful!"
      echo "=========================================="

      # Get deployment summary
      aws deploy get-deployment \
        --deployment-id "$DEPLOYMENT_ID" \
        --region "$AWS_REGION" \
        --query 'deploymentInfo.{Status:status,Creator:creator,CreateTime:createTime,CompleteTime:completeTime}' \
        --output table

      exit 0
      ;;

    "Failed"|"Stopped")
      echo ""
      echo "=========================================="
      echo "❌ Deployment $STATUS"
      echo "=========================================="

      # Get error information
      echo "Error details:"
      aws deploy get-deployment \
        --deployment-id "$DEPLOYMENT_ID" \
        --region "$AWS_REGION" \
        --query 'deploymentInfo.errorInformation' \
        --output table

      # Get instance statuses
      echo ""
      echo "Instance statuses:"
      aws deploy list-deployment-instances \
        --deployment-id "$DEPLOYMENT_ID" \
        --region "$AWS_REGION" \
        --query 'instancesList' \
        --output text | while read -r INSTANCE_ID; do
          echo "Instance $INSTANCE_ID:"
          aws deploy get-deployment-instance \
            --deployment-id "$DEPLOYMENT_ID" \
            --instance-id "$INSTANCE_ID" \
            --region "$AWS_REGION" \
            --query 'instanceSummary.{Status:status,LifecycleEvents:lifecycleEvents[*].{Event:lifecycleEventName,Status:status,DiagnosticsMessage:diagnostics.message}}' \
            --output json | jq '.'
        done

      exit 1
      ;;

    "Created"|"Queued"|"InProgress")
      printf "⏳ Status: %-20s [%3ds elapsed]\r" "$STATUS" "$ELAPSED_TIME"
      sleep $SLEEP_TIME
      ELAPSED_TIME=$((ELAPSED_TIME + SLEEP_TIME))
      ;;

    *)
      echo ""
      echo "❌ Unknown deployment status: $STATUS"
      exit 1
      ;;
  esac
done

echo ""
echo "❌ Deployment timeout after ${MAX_WAIT_TIME}s"
echo "Current status:"
aws deploy get-deployment \
  --deployment-id "$DEPLOYMENT_ID" \
  --region "$AWS_REGION" \
  --query 'deploymentInfo.status' \
  --output text

exit 1
