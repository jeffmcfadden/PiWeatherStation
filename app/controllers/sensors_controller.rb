class SensorsController < ApplicationController


  def c_to_f( c )
    (c * 1.8000 + 32.00 ).round(2)
  end

  def index
    @values_for_chart = {}
    @sensors = Sensor.all

    @sensors.each do |s|
      values = s.sensor_observations.select( 'sensor_observations.observed_at, sensor_observations.value' ).where( [ 'sensor_observations.observed_at >= ?', 24.hours.ago ] ).collect{ |so| [so.observed_at, c_to_f( so.value )] }

      @values_for_chart[s.id] = moving_average_of_values( values )
    end

  end

  def take_sensor_observations
    Sensor.all.each do |s|
      s.take_observation!
    end

    render json: { "ok" => "ok" }
  end

  def show
    @sensor = Sensor.find( params[:id] )

    sensor_for_json = {
      sensor: @sensor,
      latest: @sensor.sensor_observations.order( observed_at: :desc ).limit(1).first
    }

    respond_to do |format|
      format.html
      format.json {
        render :json => sensor_for_json
      }
    end
  end

  private

  def moving_average_of_values( v )
    moving_averaged = []

    stack = []

    v.each do |d|
      stack.push d[1]

      stack.shift if stack.size > 3

      this_temp = stack.sum / stack.size.to_f

      moving_averaged.push( [d[0], this_temp] )
    end

    moving_averaged
  end

end
