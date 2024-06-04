FROM postgres:16

RUN apt-get update && apt-get install -y \
    postgresql-13-vector \
    && rm -rf /var/lib/apt/lists/*
