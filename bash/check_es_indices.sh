#!/bin/bash
# ============================
# Elasticsearch Index & Shard Check Script
# Usage: ./check_es_indices.sh [ES_HOST] [ES_PORT]
# Default: ES_HOST=localhost, ES_PORT=9200
# ============================

ES_HOST=${1:-"localhost"}
ES_PORT=${2:-"9200"}

echo "🔍 Connecting to Elasticsearch: http://$ES_HOST:$ES_PORT"

# Check cluster health
echo -e "\n=== Cluster Health ==="
curl -s "http://$ES_HOST:$ES_PORT/_cluster/health?pretty"

# List indices sorted by store size
echo -e "\n=== Indices (sorted by store size) ==="
curl -s "http://$ES_HOST:$ES_PORT/_cat/indices?v&bytes=gb&s=store.size:desc"

# Check shard allocation details
echo -e "\n=== Shard Allocation Details ==="
curl -s "http://$ES_HOST:$ES_PORT/_cat/shards?v"

# Count small shards (< 1GB)
echo -e "\n=== Number of Small Shards (< 1GB) ==="
curl -s "http://$ES_HOST:$ES_PORT/_cat/shards?h=index,shard,store,node" \
  | awk '{if($3+0 < 1) print $0}' | wc -l

# List the 20 smallest shards
echo -e "\n=== 20 Smallest Shards ==="
curl -s "http://$ES_HOST:$ES_PORT/_cat/shards?h=index,shard,store,node" \
  | sort -k3 -n | head -20
