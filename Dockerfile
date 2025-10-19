# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy chỉ pubspec để cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy toàn bộ source code
COPY . .

# Build Flutter Web với verbose để debug nếu fail
RUN flutter build web --release -v

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
