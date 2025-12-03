# Use nginx alpine for a lightweight web server
FROM nginx:alpine

# Copy the built Flutter web app to nginx html directory
COPY build/web /usr/share/nginx/html

# Copy custom nginx configuration for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
