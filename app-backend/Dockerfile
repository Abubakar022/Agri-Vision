# Stage 1: Build Stage (Dependencies install karna)
FROM node:20-alpine AS builder

# Working Directory set karein
WORKDIR /app

# Package files copy karein. Yeh sirf dependency files hain.
COPY package.json package-lock.json ./

# Production dependencies install karein
RUN npm ci --omit=dev

# Stage 2: Production Stage (Final small image)
FROM node:20-alpine

# Set Working Directory again for the final image
WORKDIR /app

# Dependencies copy karein 'builder' stage se
COPY --from=builder /app/node_modules ./node_modules

# Baqi application files copy karein
# Is mein aapki saari folders (config, controllers, modules, routes, services, utils) shamil hain.
COPY . .

# Cloud environment (jaise Cloud Run) 8080 port par request bhejta hai.
# Aapki application process.env.PORT ya 5000 use kar rahi hai,
# Lekin container ke andar Cloud Run ki zaroorat ke mutabiq 8080 par sunna zaruri hai.
# Isliye hum default port 8080 set karte hain.
ENV PORT 8080

# PORT ko expose karna (optional, lekin achi practice hai)
EXPOSE 8080

# Application ko chalanay ka command (index.js entry point hai)
CMD ["node", "index.js"]