FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install jsreport CLI globally
RUN npm install -g @jsreport/jsreport-cli

# Copy jsreport directory contents
COPY jsreport/package*.json ./
COPY jsreport/ ./

# Install dependencies
RUN npm install

# Expose default jsreport port
EXPOSE 5488

# Start jsreport
CMD ["jsreport", "start"]