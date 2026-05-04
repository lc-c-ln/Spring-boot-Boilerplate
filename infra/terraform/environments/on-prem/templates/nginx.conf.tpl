server {
    listen 80;
    server_name _;

    location / {
        proxy_pass         http://app:${app_port};
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
    }

    location /actuator/health {
        proxy_pass http://app:${app_port}/actuator/health;
        access_log off;
    }
}
