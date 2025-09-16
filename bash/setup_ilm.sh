#!/bin/bash
# =====================================================
# Elasticsearch ILM Setup Script
# Function: Keep logs for N days, then delete
# Usage:
#   ./setup_ilm.sh <ES_HOST> <RETENTION_DAYS>
# Example:
#   ./setup_ilm.sh "http://127.0.0.1:9200" 30
# =====================================================

# Parameters
ES_HOST=$1
RETENTION_DAYS=$2

# Check parameters
if [ -z "$ES_HOST" ] || [ -z "$RETENTION_DAYS" ]; then
  echo "Usage: $0 <ES_HOST> <RETENTION_DAYS>"
  exit 1
fi

POLICY_NAME="logs-retention-${RETENTION_DAYS}d"
INDEX_TEMPLATE="logstash_template"

echo ">>> Creating ILM policy: keep logs for ${RETENTION_DAYS} days, then delete"
curl -XPUT "$ES_HOST/_ilm/policy/$POLICY_NAME" \
  -H "Content-Type: application/json" -d "{
    \"policy\": {
      \"phases\": {
        \"hot\": {
          \"actions\": {}
        },
        \"delete\": {
          \"min_age\": \"${RETENTION_DAYS}d\",
          \"actions\": {
            \"delete\": {}
          }
        }
      }
    }
  }"
echo -e "\n✅ Policy created successfully\n"

echo ">>> Creating/Updating index template: ${INDEX_TEMPLATE}"
curl -XPUT "$ES_HOST/_template/$INDEX_TEMPLATE" \
  -H "Content-Type: application/json" -d "{
    \"index_patterns\": [\"logstash-*\"] ,
    \"settings\": {
      \"number_of_shards\": 1,
      \"number_of_replicas\": 0,
      \"index.lifecycle.name\": \"$POLICY_NAME\",
      \"index.lifecycle.rollover_alias\": \"logstash\"
    }
  }"
echo -e "\n✅ Index template created/updated successfully\n"

echo ">>> Updating existing indices (logstash-*) to use policy: ${POLICY_NAME}"
curl -XPUT "$ES_HOST/logstash-*/_settings" \
  -H "Content-Type: application/json" -d "{
    \"index\": {
      \"lifecycle\": {
        \"name\": \"$POLICY_NAME\"
      }
    }
  }"
echo -e "\n✅ Existing indices updated to use ILM policy\n"

echo ">>> Checking ILM policy:"
curl -XGET "$ES_HOST/_ilm/policy/$POLICY_NAME?pretty"

echo -e "\n>>> Script execution completed ✅\n"
