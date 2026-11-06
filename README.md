# infra-monitoring-project

Система мониторинга доступности echo-сервера: Bash-скрипты для проверки API и анализа логов,
Docker Compose стек (echo-сервис + nginx-прокси) и CI/CD на GitHub Actions.

## Структура проекта

```
.
├── .github/workflows/ci.yml   # CI/CD пайплайн
├── scripts/
│   ├── check_api.sh           # проверка доступности API
│   └── analyze_logs.sh        # генерация и анализ access.log
├── docker-compose.yml         # сервисы api и proxy
├── nginx.conf                 # конфиг nginx (проксирование 80 → api:8080)
├── .gitignore
└── README.md
```

## Запуск скриптов

```bash
chmod +x scripts/check_api.sh scripts/analyze_logs.sh
```

### check_api.sh

Принимает URL, делает запрос через `curl` и проверяет код ответа (ожидается 200).
Возвращает 0, если API доступен, и 1 при ошибке.

```bash
./scripts/check_api.sh https://httpbin.org/status/200
# API доступен (код ответа: 200)

./scripts/check_api.sh https://httpbin.org/status/404
# API недоступен, код ответа: 404

echo $?   # код возврата последней команды
```

### analyze_logs.sh

Генерирует тестовый `access.log` (600 строк) и выводит:
- общее количество запросов;
- топ-3 IP-адреса по числу запросов;
- количество запросов с кодами 4xx и 5xx.

```bash
./scripts/analyze_logs.sh
```

## Деплой на удалённый сервер (SSH / SCP)

В примерах `user@remote_host` — пользователь и IP-адрес (или домен) сервера.

### 1. Генерация SSH-ключей

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

- `-t rsa` — тип ключа;
- `-b 4096` — длина ключа в битах;
- `-f ~/.ssh/id_rsa` — файл, куда сохранить ключ.

Создаётся пара ключей:
- `~/.ssh/id_rsa` — **приватный** ключ, хранится только у себя и никому не передаётся;
- `~/.ssh/id_rsa.pub` — **публичный** ключ, копируется на сервер.

Посмотреть отпечаток ключа:

```bash
ssh-keygen -l -f ~/.ssh/id_rsa.pub
```

### 2. Копирование публичного ключа на сервер

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@remote_host
```

Публичный ключ добавляется в `~/.ssh/authorized_keys` на сервере.
Проверка входа по ключу (без пароля):

```bash
ssh user@remote_host
ssh -i ~/.ssh/id_rsa user@remote_host     # явно указать ключ
ssh -p 2222 user@remote_host              # если SSH работает не на порту 22
```

Чтобы не вводить пароль от ключа при каждом подключении, ключ можно добавить в `ssh-agent`:

```bash
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

### 3. Передача проекта на сервер

**Вариант 1 — scp каталога целиком** (`-r` — рекурсивно):

```bash
scp -r ./infra-monitoring-project user@remote_host:~/
```

**Вариант 2 — tar + ssh**:

```bash
tar -czf - --exclude=.git infra-monitoring-project | ssh user@remote_host "tar -xzf - -C ~/"
```
### 4. Запуск на сервере

```bash
ssh user@remote_host
cd ~/infra-monitoring-project
docker compose up -d
./scripts/check_api.sh http://localhost:80
```
