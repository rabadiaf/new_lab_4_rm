# Usa una imagen base oficial ligera
FROM ubuntu:20.04

# Evita prompts interactivos en apt
ENV DEBIAN_FRONTEND=noninteractive

# Instala nginx y limpia cache de apt para reducir tamaño
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expone el puerto 80 (HTTP)
EXPOSE 80

# Ejecuta nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]

