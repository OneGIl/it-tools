FROM node:20.10.0-alpine3.18 AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /app

FROM base AS deps
COPY package.json ./
COPY pnpm-lock.yaml ./
RUN npm config set registry https://registry.npmmirror.com/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm add -D vite

FROM deps AS build
COPY / /app
RUN pnpm build

FROM --platform=linux/amd64 nginx:1.25.3-alpine3.18-slim
RUN rm /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
