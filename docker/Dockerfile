# ---- build stage ----
FROM node:20-alpine AS build
WORKDIR /app
# Only copy manifest first for better layer caching
COPY package*.json ./
RUN npm ci --omit=dev
# Copy app
COPY app.js ./

# ---- runtime stage ----
FROM node:20-alpine
# Create non-root user & group
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
# Copy only needed runtime files
COPY --from=build /app /app
# Drop privileges
USER app
EXPOSE 3000
# Healthcheck (optional—works locally, ALB does health in AWS)
HEALTHCHECK --interval=30s --timeout=3s CMD node -e "fetch('http://127.0.0.1:3000').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "app.js"]
