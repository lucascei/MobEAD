# Imagem da aplicação MobEAD (site estático com Nginx)
FROM nginx:alpine

LABEL maintainer="Lucas Alves"
LABEL description="MobEAD - Aplicação de treinamento DevOps"

# Remove página padrão do Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copia arquivos estáticos da aplicação
COPY index.html kickstrap.css mine.css /usr/share/nginx/html/
COPY Scripts/ /usr/share/nginx/html/Scripts/
COPY Kickstrap/ /usr/share/nginx/html/Kickstrap/
COPY lib/ /usr/share/nginx/html/lib/

# Configuração customizada do Nginx
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Banner de ambiente (substituído no deploy via variável)
ENV APP_ENV=development

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost/ | grep -q "MobEAD" || exit 1

CMD ["nginx", "-g", "daemon off;"]
