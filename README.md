# README

## Do these things after boot:

    sudo modprobe w1-gpio
    sudo modprobe w1-therm

## Unicorn


    Start:

    cd /www/weather_station; bundle exec unicorn_rails -c config/unicorn.rb -E production -D

    Or, once upstart is setup:

    sudo start unicorn (which should run on boot anyway)

    Restart:

    sudo kill -HUP `cat /www/weather_station/pids/unicorn.pid`


## Setting up the Pi:

    sudo apt-get update

    mkdir installs
    cd installs
    sudo apt-get install git
    git clone https://github.com/ruby/ruby.git  #This takes forever
    cd ruby
    git checkout tags/v2_2_2
    sudo apt-get install autoconf
    autoconf
    sudo apt-get install gcc g++ make ruby1.9.1 bison libyaml-dev libssl-dev libffi-dev zlib1g-dev libxslt-dev libxml2-dev libpq-dev zip nodejs vim libreadline-dev

     # RPi B+ ONLY:
    ./configure --disable-install-doc && make clean && make && sudo make install

    # RPi 2 ONLY:
    ./configure --disable-install-doc && make clean && make -j4 && sudo make install


    # Wiring Pi:
    cd ~/installs
    git clone git://git.drogon.net/wiringPi
    cd wiringPi
    ./build
    # Run this to be sure things are working:
    # gpio -v
    # gpio readall

    sudo apt-get install postgresql postgresql-contrib libpq-dev

    sudo -i -u postgres
    createuser -s -P rails
    exit

    sudo vim /etc/postgresql/9.1/main/pg_hba.conf

    # change the 'peer' to 'md5' NOT THE LOCAL ONE, LEAVE TO TRUST OR EVERYTHING BREAKS

    sudo service postgresql restart

    sudo mkdir /www
    sudo chown pi:pi /www
    cd /www
    sudo git clone https://github.com/jeffmcfadden/PiWeatherStation.git
    mv PiWeatherStation weather_station
    cd weather_station
    echo "install: --no-rdoc --no-ri" >> ~/.gemrc
    echo "update:  --no-rdoc --no-ri" >> ~/.gemrc
    echo "gem: --no-rdoc --no-ri" >> ~/.gemrc
    sudo gem install bundler
    bundle install
    RAILS_ENV=production bundle exec rake db:create
    RAILS_ENV=production bundle exec rake db:migrate

    sudo apt-get install nginx

    sudo apt-get install upstart # Ignore the warnings. This will be ok

    # Reboot

    # install the weather_station.conf for nginx
    # install the unicorn.conf for upstart to /etc/init/unicorn.conf
    # install the crontab via crontab -e

    sudo nginx

    # this should work now:
    rails c production

    # setup your application.yml

    RAILS_ENV=production bundle exec rake assets:precompile

    mkdir pids
    bundle exec unicorn_rails -c config/unicorn.rb -E production -D