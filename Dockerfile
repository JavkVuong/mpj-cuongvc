# syntax=docker/dockerfile:1.7

FROM node:20-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app


FROM base AS dependencies

COPY package.json pnpm-lock.yaml ./

RUN corepack prepare pnpm@10.34.5 --activate \
    && pnpm --version \
    && pnpm install --frozen-lockfile


FROM base AS builder

ARG NEXT_PUBLIC_SERVER_URL=http://localhost:3000

ENV NEXT_PUBLIC_SERVER_URL=$NEXT_PUBLIC_SERVER_URL
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

RUN --mount=type=secret,id=PAYLOAD_SECRET,required=true \
    --mount=type=secret,id=DATABASE_URL,required=true \
    PAYLOAD_SECRET="$(cat /run/secrets/PAYLOAD_SECRET)" \
    DATABASE_URL="$(cat /run/secrets/DATABASE_URL)" \
    pnpm build


FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs \
    && mkdir -p /app/public/media \
    && chown -R nextjs:nodejs /app

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

RUN mkdir -p /app/public/media \
    && chown -R nextjs:nodejs /app/public/media

USER nextjs

EXPOSE 3000

CMD ["node", "server.js"]
