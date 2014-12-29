# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/www/weather_station"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/www/weather_station/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/www/weather_station/log/unicorn.log"
stdout_path "/www/weather_station/log/unicorn.log"

# Unicorn socket
#listen "/tmp/unicorn..sock"
listen "/tmp/unicorn.weather_station.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
