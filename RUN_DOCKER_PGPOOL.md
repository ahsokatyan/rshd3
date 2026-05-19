# Запуск работы с pgpool-II в Docker

В этой схеме PostgreSQL работает на ВМ `pg136` и `pg135`, а `pgpool-II` запускается локально в Docker на Windows/WSL.

## Терминалы

Нужно три терминала.

Терминал 1: SSH-туннели, локально в WSL/Git Bash. Его нужно держать открытым:

```sh
ssh -J s367056@se.ifmo.ru:2222 -L 9909:pg136:9909 -L 9910:pg135:9909 postgres3@pg135
```

Терминал 2: локальный WSL в корне репозитория:

```sh
cd /mnt/c/Users/79534/Desktop/rshd3
```

Терминал 3: подключение к `pg135`:

```sh
ssh -J s367056@se.ifmo.ru:2222 postgres3@pg135
cd ~/rshd3
```

## Этап 1

На `pg135` выполнить серверную подготовку PostgreSQL:

```sh
sh scripts/stage1/00-start-primary-cluster.sh
sh scripts/stage1/01-init-primary.sh
sh scripts/stage1/02-init-standby.sh
```

Локально в WSL запустить `pgpool-II` в Docker:

```sh
PRIMARY_HOST=host.docker.internal PRIMARY_PORT=9909 STANDBY_HOST=host.docker.internal STANDBY_PORT=9910 PGPOOL_HOST=127.0.0.1 sh scripts/stage1/03-config-pgpool.sh
```

Локально в WSL выполнить демонстрацию работы через `pgpool`:

```sh
sh scripts/stage1/04-demo-load-balance-docker.sh
```

## Этап 2

Локально в WSL показать клиентскую работу до сбоя:

```sh
sh scripts/stage2/01-client-read-write-docker.sh
```

На `pg135` имитировать отказ primary:

```sh
sh scripts/stage2/02-destroy-primary-pgdata.sh
```

Локально в WSL посмотреть лог `pgpool`:

```sh
sh scripts/stage2/03-show-pgpool-logs-docker.sh
```

На `pg135` посмотреть лог standby:

```sh
sh scripts/stage2/03-show-failure-logs.sh
```

На `pg135` выполнить failover standby в primary:

```sh
sh scripts/stage2/04-failover-to-standby.sh
```

Локально в WSL перезапустить `pgpool` после failover:

```sh
sh scripts/stage2/04-restart-pgpool-docker.sh
```

Локально в WSL проверить работу после failover:

```sh
sh scripts/stage2/05-demo-after-failover-docker.sh
```

## Восстановление

На `pg135` пересоздать старый primary `pg136` из текущего primary `pg135`:

```sh
sh scripts/restore/01-rebuild-old-primary.sh
```

На `pg135` вернуть исходную схему `pg136 primary`, `pg135 standby`:

```sh
sh scripts/restore/02-return-original-primary.sh
```

Локально в WSL перезапустить `pgpool` после восстановления:

```sh
sh scripts/restore/02-restart-pgpool-docker.sh
```

Локально в WSL проверить восстановленный кластер:

```sh
sh scripts/restore/03-demo-restored-cluster-docker.sh
```
