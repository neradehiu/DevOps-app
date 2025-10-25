# =========================
# 1️⃣ Stage build Flutter Web
# =========================
FROM debian:stable-slim AS build
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa chromium

# Cài Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Kiểm tra Flutter
RUN flutter --version

# Sao chép source code
WORKDIR /app
COPY . .

# Bật chế độ web
RUN flutter config --enable-web

# Build Flutter Web (release)
RUN flutter build web --release --dart-define=DOCKER_ENV=true && ls -l build/web

# =========================
# 2️⃣ Stage chạy Nginx
# =========================
FROM nginx:stable-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
