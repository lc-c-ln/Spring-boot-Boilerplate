services:
  app:
    image: ${ecr_image}
    env_file: /opt/${app_name}/.env
    ports:
      - "${app_port}:${app_port}"
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:${app_port}/actuator/health || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 60s

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${db_name}
      POSTGRES_USER: ${db_username}
      POSTGRES_PASSWORD: ${db_password}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${db_username}"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
    volumes:
      - /opt/${app_name}/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
