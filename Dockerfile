FROM alpine:latest

# Устанавливаем xray и curl
RUN apk add --no-cache xray curl

# Копируем конфигурацию (мы создадим её прямо в Dockerfile для простоты)
RUN mkdir -p /etc/xray
RUN echo '{\
  "log": { "loglevel": "warning" },\
  "inbounds": [{\
    "port": 8080,\
    "protocol": "vless",\
    "settings": {\
      "clients": [{ "id": "a1217430-8f5d-4021-8d15-2c7d4108b8ca" }],\
      "decryption": "none"\
    },\
    "streamSettings": {\
      "network": "ws",\
      "wsSettings": { "path": "/gemini-tunnel" }\
    }\
  }],\
  "outbounds": [{\
    "protocol": "freedom",\
    "settings": {}\
  }]\
}' > /etc/xray/config.json

# Railway передает порт через переменную среды PORT, подменим его перед запуском
CMD sed -i "s/8080/$PORT/g" /etc/xray/config.json && xray run -c /etc/xray/config.json
