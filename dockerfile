# Используем базовый образ Python 2.7
FROM python:2.7

# Устанавливаем зависимости системы
RUN apt-get update && apt-get install -y \
    build-essential \
    redis-server \
    memcached \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем GeoIP C API из альтернативного URL
RUN wget https://github.com/maxmind/geoip-api-c/archive/refs/tags/v1.6.9.tar.gz -O GeoIP-1.6.9.tar.gz && \
    tar -xzf GeoIP-1.6.9.tar.gz && \
    cd geoip-api-c-1.6.9 && \
    ./configure && \
    make && \
    make install && \
    rm -rf geoip-api-c-1.6.9 geoip-1.6.9.tar.gz

# Устанавливаем зависимости Python
COPY pip-req.txt /app/pip-req.txt
RUN pip install -r /app/pip-req.txt

# Копируем исходный код приложения
COPY . /app

# Устанавливаем рабочую директорию
WORKDIR /app

# Выполняем миграцию базы данных
RUN python manage.py syncdb --noinput

# Экспонируем порт
EXPOSE 8000

# Стартовые команды
CMD ["sh", "-c", "python manage.py runserver 0.0.0.0:8000 & python pubsub.py"]