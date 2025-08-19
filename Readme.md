# up
```
sudo docker-compose -f {file.yml} up --build -d
```

# down
```
sudo docker-compose -f {file.yml} down
```

# Clear docker log
```
cd /var/lib/docker/containers
sudo find  -name "*.log" -exec truncate -s 0 {} \;
sudo docker restart $(docker ps -q)
```

# View dir size
```
sudo du -h --max-depth=1 /var/lib/docker/containers | sort -hr
```