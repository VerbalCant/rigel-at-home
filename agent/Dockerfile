# Use a full Node image instead of Alpine to avoid musl compatibility issues
FROM node:18-slim

# Set the working directory in the container to /app
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies with specific platform handling
RUN apt-get update && \
    apt-get install -y python3 make g++ && \
    npm install --platform=linux --arch=arm64 && \
    npm rebuild && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the rest of your application code
COPY . .

# Expose the correct ports
EXPOSE 4000 3001

# Configure Vite to listen on all interfaces
ENV VITE_HOST=0.0.0.0
ENV VITE_PORT=3001

# Start the Vite dev server
CMD ["npm", "run", "dev:vite"] 