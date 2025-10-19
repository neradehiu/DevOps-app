# --- Stage 1: Build Flutter Web App ---
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cài đặt dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy mã nguồn và build ứng dụng
COPY . .
RUN flutter build web --release

# --- Stage 2: Serve with Nginx ---
FROM nginx:stable-alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
