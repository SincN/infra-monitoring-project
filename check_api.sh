#!/usr/bin/env bash

if [[ $# -lt 1 || $# -gt 1 ]]; then
    echo "Использование: $0 <URL>" >&2
    exit 1
fi

URL="$1"

# URL должен начинаться с http:// или https://
if [[ ! "$URL" =~ ^https?://[^[:space:]/]+ ]]; then
    echo "Ошибка: некорректный URL '$URL' (ожидается http:// или https://)" >&2
    exit 1
fi

# Проверка наличия curl
if ! command -v curl >/dev/null 2>&1; then
    echo "Ошибка: curl не установлен" >&2
    exit 1
fi

# -s  без прогресса, -o /dev/null тело не нужно, -w выводит только HTTP-код.
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' \
--connect-timeout 5 --max-time 15 --retry 2 --retry-delay 1 \
"$URL")
CURL_RC=$?

if [[ "$HTTP_CODE" == "200" ]]; then
    echo "API доступен (код ответа: $HTTP_CODE)"
    exit 0
else
    echo "API недоступен, код ответа: $HTTP_CODE (ошибка curl: $CURL_RC)"
fi

exit 1
