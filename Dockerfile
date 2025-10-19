# Serve Flutter Web với Nginx
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

# Copy build đã được tạo ra từ Flutter Web
COPY build/web .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
