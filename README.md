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
