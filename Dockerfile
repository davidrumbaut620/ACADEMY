FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    unzip \
    git \
    libonig-dev \
    && docker-php-ext-install \
       bcmath \
       ctype \
       pdo \
       pdo_mysql \
       tokenizer \
       xml \
       zip \
       gd \
       intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg

# Habilitar extensiones ya incluidas en PHP >= 8.2
RUN docker-php-ext-enable \
    json \
    mbstring \
    openssl \
    fileinfo \
    bcmath \
    intl \
    gd

# Habilitar mod_rewrite (por si usas .htaccess)
RUN a2enmod rewrite

# Configuración de Apache
COPY ./docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Copiar tu aplicación
WORKDIR /var/www/html
COPY . .

# Crear y asegurar permisos de storage y logs
RUN mkdir -p storage/logs \
    && chmod -R 775 storage storage/logs \
    && chown -R www-data:www-data storage storage/logs

# Asegurar .env
RUN test -f .env || cp .env.example .env \
    && chmod 664 .env \
    && chown www-data:www-data .env

# Exponer puerto
EXPOSE 80

# Iniciar Apache
CMD ["apache2-foreground"]
