FROM prom/prometheus:latest

# Copy custom Prometheus configuration
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Set proper permissions
RUN chown -R nobody:nogroup /etc/prometheus/prometheus.yml

# Expose Prometheus port
EXPOSE 9090

# Use default entrypoint from base image
# Prometheus will automatically read from /etc/prometheus/prometheus.yml
