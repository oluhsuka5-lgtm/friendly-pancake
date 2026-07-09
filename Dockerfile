FROM debian:bullseye-slim

# Устанавливаем нужные программы для скачивания
RUN apt-get update && apt-get install -y curl unzip

# Скачиваем Xray напрямую с официального сайта
RUN curl -L -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm xray.zip

# Создаем конфиг
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

# Подменяем порт и запускаем
CMD sed -i "s/8080/$PORT/g" /etc/xray/config.json && /usr/local/bin/xray run -c /etc/xray/config.json
