class SensorsController < ApplicationController

  def c_to_f( c )
    (c * 1.8000 + 32.00 ).round(2)
  end

  def index
    @values_for_chart = {}
    @sensors = Sensor.all

    @sensors.each do |s|
      values = s.sensor_observations.select( 'sensor_observations.observed_at, sensor_observations.value' ).where( [ 'sensor_observations.observed_at >= ?', 24.hours.ago ] ).collect{ |so| [so.observed_at, c_to_f( so.value )] }

      @values_for_chart[s.id] = values
    end

  end

  def take_sensor_observations
    Sensor.all.each do |s|
      s.take_observation!
    end

    render json: { "ok" => "ok" }
  end

end
