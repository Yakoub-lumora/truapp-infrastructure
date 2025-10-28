FROM prom/prometheus:v2.47.0

# Copy custom Prometheus configuration
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Prometheus runs as 'nobody' user by default in the base image
# The config file is already in the correct location

# Expose Prometheus port
EXPOSE 9090

# Use default entrypoint from base image
# Prometheus will automatically read from /etc/prometheus/prometheus.yml
