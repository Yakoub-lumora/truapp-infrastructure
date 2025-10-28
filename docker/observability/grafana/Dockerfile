FROM grafana/grafana:10.2.0

# Copy datasource provisioning config
COPY provisioning/datasources/datasources.yml /etc/grafana/provisioning/datasources/datasources.yml
COPY provisioning/datasources/prometheus.json /etc/grafana/provisioning/datasources/prometheus.json

# Copy dashboard provisioning config
COPY provisioning/dashboards/dashboards.yml /etc/grafana/provisioning/dashboards/dashboards.yml
COPY provisioning/dashboards/trushot-app-monitoring.json /etc/grafana/provisioning/dashboards/trushot-app-monitoring.json

# Set proper permissions
RUN chown -R grafana:grafana /etc/grafana/provisioning

# Expose Grafana port
EXPOSE 3000
