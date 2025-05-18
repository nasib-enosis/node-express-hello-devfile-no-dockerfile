# the official Node.js runtime as base image that the build will extend
FROM node:18

# Set the working directory in the image where files will be copied and commands will be executed
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to install dependencies first (better layer caching)
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the remaining app files
COPY . .

# Expose the port the app runs on
EXPOSE 8888

# Set environment variable PORT
ENV PORT=8888

# Define the command to run the app
CMD ["node", "app.js"]
