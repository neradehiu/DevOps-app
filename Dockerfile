# =========================
# 1️⃣ Stage build Flutter
# =========================
FROM debian:stable-slim AS build
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Cài Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Kiểm tra Flutter
RUN flutter --version

# Copy source code vào container
WORKDIR /app
COPY . .

# Build web (gắn cờ môi trường Docker)
RUN flutter build web --release --dart-define=DOCKER_ENV=true

# =========================
# 2️⃣ Stage chạy với Nginx
# =========================
FROM nginx:stable-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
