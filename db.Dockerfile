FROM postgres:17

RUN apt-get update && apt-get install -y \
    postgresql-13-vector \
    && rm -rf /var/lib/apt/lists/*
