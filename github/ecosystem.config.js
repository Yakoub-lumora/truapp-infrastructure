module.exports = {
  apps: [
    {
      name: 'trushot-app',
      script: 'node_modules/next/dist/bin/next',
      args: 'start',
      cwd: '/opt/app',
      instances: 'max',
      exec_mode: 'cluster',
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      error_file: '/opt/app/logs/error.log',
      out_file: '/opt/app/logs/out.log',
      log_file: '/opt/app/logs/combined.log',
      time: true,
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 10000,
      shutdown_with_message: true,
    },
  ],
};
