# 构建阶段
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm -g install pnpm --registry=https://registry.npmmirror.com
RUN pnpm install --registry=https://registry.npmmirror.com
RUN pnpm run build

# 运行阶段
FROM nginx:1.25.1-alpine3.17-slim
COPY --from=builder /app/dist /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
