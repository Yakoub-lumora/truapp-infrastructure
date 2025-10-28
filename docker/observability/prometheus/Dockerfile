FROM prom/prometheus:v2.47.0

# Copy custom Prometheus configuration
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Set proper permissions
RUN chown -R nobody:nogroup /etc/prometheus/prometheus.yml

# Expose Prometheus port
EXPOSE 9090

# Use default entrypoint from base image
# Prometheus will automatically read from /etc/prometheus/prometheus.yml
