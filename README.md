# Liferay DXP Docker Compose Environment

## Requirements

* Docker & Docker Compose - https://www.docker.com/
* Make - https://www.make.com/

## Setup

Start the compose:

```
make up
```

Tail the log:

```
docker compose logs -f liferay
```

Stop the stack

```
docker compose stop
```

Destroy

```
make down
```


