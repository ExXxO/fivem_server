# FiveM - Dockercontainer

Generate a compose deployment like this:

```yaml
version: '3.8'
services:
# -------------------------------------------------------------------
  fsx:
    image: astreon/fivem:6736
    container_name: gameserver
    stdin_open: true
    tty: true
    volumes:
      - ./server_data:/txData
    ports:
      - 30120:30120
      - 30120:30120/udp
      - 40120:40120
    environment:
      SERVER_PROFILE: default
      FIVEM_PORT: 30120
      TXADMIN_PORT: 40120
      # Uncomment for using local linux file privileges, which is recommended
      #HOST_UID: 1000
      #HOST_GID: 100
    depends_on:
      - database
# -------------------------------------------------------------------
  database:
    image: mariadb
    restart: always
    container_name: database
    volumes:
      - ./database:/var/lib/mysql
    environment:
      # Generate a HASH with a SQL Client => SELECT PASSWORD('changeme') | or | use MARIADB_ROOT_PASSWORD for open formated text
      MARIADB_ROOT_PASSWORD_HASH: ""
      MARIADB_DATABASE: fsx_default
# -------------------------------------------------------------------
  sshtunnel:
    image: ghcr.io/linuxserver/openssh-server
    restart: unless-stopped
    container_name: sshtunnel
    ports:
      - 6280:2222
    volumes:
      - /home/fivem/.ssh/authorized_keys:/etc/tunnel/authorized_keys
      - ./openssh/sshd_config:/config/ssh_host_keys
    environment:
      - PUBLIC_KEY_FILE=/etc/tunnel/authorized_keys
      - USER_NAME=proxy
      - SUDO_ACCESS=true
      - PASSWORD_ACCESS=false
```

If you want to use Let's Encrypt secured txAdmin Panel then use deployment as follow
```yaml
version: '3.8'
services:
# -------------------------------------------------------------------
  fsx:
    image: astreon/fivem:6736
    container_name: gameserver
    stdin_open: true
    tty: true
    labels:
      - traefik.http.routers.fsx.rule=Host(`YOUR DOMAIN NAME`)
      - traefik.http.services.txadmin.loadbalancer.server.port=40120
      - traefik.http.routers.fsx.tls=true
      - traefik.http.routers.fsx.tls.certresolver=myresolver
    volumes:
      - ./server_data:/txData
    ports:
      - 30120:30120
      - 30120:30120/udp
      - 40120:40120
    environment:
      SERVER_PROFILE: default
      FIVEM_PORT: 30120
      TXADMIN_PORT: 40120
      # Uncomment for using local linux file privileges, which is recommended
      #HOST_UID: 1000
      #HOST_GID: 100
    depends_on:
      - database
# -------------------------------------------------------------------
  database:
    image: mariadb
    restart: always
    container_name: database
    volumes:
      - ./database:/var/lib/mysql
    environment:
      # Generate a HASH with a SQL Client => SELECT PASSWORD('changeme') | or | use MARIADB_ROOT_PASSWORD for open formated text
      MARIADB_ROOT_PASSWORD_HASH: ""
      MARIADB_DATABASE: fsx_default
# -------------------------------------------------------------------
  sshtunnel:
    image: ghcr.io/linuxserver/openssh-server
    restart: unless-stopped
    container_name: sshtunnel
    ports:
      - 6280:2222
    volumes:
      - /home/fivem/.ssh/authorized_keys:/etc/tunnel/authorized_keys
      - ./openssh/sshd_config:/config/ssh_host_keys
    environment:
      - PUBLIC_KEY_FILE=/etc/tunnel/authorized_keys
      - USER_NAME=proxy
      - SUDO_ACCESS=true
      - PASSWORD_ACCESS=false
# -------------------------------------------------------------------
  traefik:
    image: traefik:2.10
    restart: unless-stopped
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./traefik.yaml:/etc/traefik/traefik.yaml
      - ./traefik:/data
      - /var/run/docker.sock:/var/run/docker.sock
# -------------------------------------------------------------------
```

Create the traefik.yaml as follow:
```yaml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
  websecure:
    address: ":443"

providers:
  docker: {}

certificatesResolvers:
  myresolver:
    acme:
      email: hostmaster@astreon.network
      storage: /data/letsencrypt.json
      httpChallenge:
        entryPoint: web
```
