# sudo irb because pi_piper requires root

require 'pi_piper'
require 'net/http'
require 'json'

@readings = []

def averaged_reading( raw_value )
  @readings.push( raw_value )

  if @readings.size > 12
    @readings.shift
  end

  @readings.inject{ |sum, el| sum + el }.to_f / @readings.size.to_f
end

adc_num = 0
n = 0

loop do
  value = 0
  PiPiper::Spi.begin do |spi|
    raw = spi.write [1, (8+adc_num)<<4, 0]
    value = ((raw[1]&3) << 8) + raw[2]
  end

  mvolts = 5000 * (value.to_f / 1023.0)

  v = mvolts / 1000.0
  # rh = ( v - 0.958) / (0.0307)

  rh = ( (v / 5.0) - 0.16 ) / 0.0062

  t = 29.4
  true_rh = (rh)/(1.0546-0.00216 * t)

  avg_rh = averaged_reading(true_rh)

  puts "value: #{value}, mvolts = #{mvolts}, v = #{v}, rh = #{rh}, true_rh = #{true_rh}, avg = #{avg_rh}"

  if n % 6 == 0
    #RH
    puts "Saving RH"
    uri = URI.parse( "http://192.168.201.182/sensors/3/record_observation" )
    response = Net::HTTP.post_form(uri, {"value" => "#{true_rh}"})

    #Get Temp
    puts "Getting Temp"
    uri = URI.parse( "http://192.168.201.182/sensors/1.json" )
    response = Net::HTTP.get(uri)
    data = JSON.parse( response )
    temp = data["sensor"]["latest_value"]
    puts "Temp: #{temp}"

    dp = ( avg_rh / 100.0 ) ** (1.0/8.0) * (112 + (0.9 * temp) ) + (0.1 * temp) - 112

    puts "DP: #{dp}"

    #DP
    puts "Saving DP"
    uri = URI.parse( "http://192.168.201.182/sensors/4/record_observation" )
    response = Net::HTTP.post_form(uri, {"value" => "#{dp}"})
  end

  n += 1
  sleep 10
end
