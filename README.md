# elk-docker-compose

```bash
cp docker-compose.yml.example docker-compose.yml

sudo mkdir -p ./elasticsearch/data && sudo chmod 777 ./elasticsearch/data

docker-compose up -d
```

open: http://127.0.0.1:5601


## Tools

### Check indices

```bash
./bash/check_es_indices.sh 127.0.0.1 9200
```

### Set replicas number to 0

```bash
curl -XPUT "127.0.0.1:9200/_all/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"number_of_replicas": 0}'
```

### Keep logs 30 days
```bash
./bash/setup_ilm.sh "http://127.0.0.1:9200" 30
```