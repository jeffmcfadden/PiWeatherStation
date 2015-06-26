require 'pi_piper'

@readings = []

def averaged_reading( raw_value )
  @readings.push( raw_value )

  if @readings.size > 12
    @readings.shift
  end

  @readings.inject{ |sum, el| sum + el }.to_f / @readings.size.to_f
end

adc_num = 0

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

  puts "value: #{value}, mvolts = #{mvolts}, v = #{v}, rh = #{rh}, true_rh = #{true_rh}, avg = #{averaged_reading(true_rh)}"
  sleep 10
end
