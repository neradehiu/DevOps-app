# --- Stage 1: Build Flutter Web App ---
FROM subosito/flutter:3.24.3 AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# --- Stage 2: Serve with Nginx ---
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
