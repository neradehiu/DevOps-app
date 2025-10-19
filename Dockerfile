# --- Stage 1: Build Flutter Web App ---
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

# Đặt thư mục làm việc
WORKDIR /app

# Copy toàn bộ source code
COPY . .

# Tải dependencies
RUN flutter pub get

# Build Flutter Web
RUN flutter build web

# --- Stage 2: Serve with Nginx ---
FROM nginx:stable-alpine

# Copy file build từ stage 1 sang thư mục Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 để truy cập web
EXPOSE 80

# Chạy Nginx
CMD ["nginx", "-g", "daemon off;"]
