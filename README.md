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
chmod +x bash/check_es_indices.sh

./check_es_indices.sh 127.0.0.1 9200
```