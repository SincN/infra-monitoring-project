#!/bin/bash
LOG_FILE="access.log"
COUNT=600

# генерация access.log
IPS=("192.168.1.10" "192.168.1.11" "10.0.0.5" "10.0.0.7" "172.16.0.3")
METHODS=("GET" "POST" "PUT" "DELETE")
URLS=("/api/auth/users" "/api/auth/login" "/api/resources/orders" "/api/resources/products")
CODES=(200 200 200 201 301 400 401 403 404 500 502 503)

> "$LOG_FILE"   # очистка файла перед записью

# сама генерация логов
for ((i = 0; i < COUNT; i++)); do
    ip=${IPS[$RANDOM % ${#IPS[@]}]}
    method=${METHODS[$RANDOM % ${#METHODS[@]}]}
    url=${URLS[$RANDOM % ${#URLS[@]}]}
    code=${CODES[$RANDOM % ${#CODES[@]}]}
    # время: начиная с 10:00:00, каждая запись на секунду позже
    time=$(printf "%02d:%02d:%02d" $((10 + i / 3600)) $((i / 60 % 60)) $((i % 60)))

    echo "$ip - - [15/Aug/2026:$time] \"$method $url HTTP/1.1\" $code" >> "$LOG_FILE"
done

echo

# анализ
IP_REGEX='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

echo "Общее количество запросов:"
# считаем строки в файле
wc -l < "$LOG_FILE"
echo

echo "Топ-3 IP-адреса:"
# грепаем IP-адреса, сортируем, схлопываем соседние одинаковые, сортируем по убыванию и выводим топ-3
grep -oE "$IP_REGEX" "$LOG_FILE" | sort | uniq -c | sort -nr | head -3
echo

echo "Количество запросов с кодами 4xx:"
# бьем строки по пробелам, считаем последние поля, подходящие под 4хх
awk '$NF ~ /^4[0-9][0-9]$/' "$LOG_FILE" | wc -l
echo

echo "Количество запросов с кодами 5xx:"
awk '$NF ~ /^5[0-9][0-9]$/' "$LOG_FILE" | wc -l
