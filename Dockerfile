# 🧱 Dùng Nginx nhẹ và ổn định
FROM nginx:stable-alpine

# Sao chép file cấu hình nginx vào container
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Sao chép build Flutter Web vào thư mục web của Nginx
COPY build/web /usr/share/nginx/html

# Mở port 80
EXPOSE 80

# Chạy nginx ở foreground
CMD ["nginx", "-g", "daemon off;"]
