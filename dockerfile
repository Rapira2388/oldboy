# Используем базовый образ Python 2.7
FROM python:2.7

# Устанавливаем зависимости системы
RUN apt-get update && apt-get install -y \
    build-essential \
    redis-server \
    memcached \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем GeoIP C API
RUN wget http://geolite.maxmind.com/download/geoip/api/c/GeoIP-1.4.8.tar.gz && \
    tar -xzf GeoIP-1.4.8.tar.gz && \
    cd GeoIP-1.4.8 && \
    ./configure && \
    make && \
    make install && \
    rm -rf /GeoIP-1.4.8* 

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