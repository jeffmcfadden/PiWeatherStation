class SensorsController < ApplicationController

  protect_from_forgery with: :null_session, only: [:record_observation]

  def c_to_f( c )
    (c * 1.8000 + 32.00 ).round(2)
  end

  def latest
    @sensors = Sensor.all.order( :id )
  end

  def index
    @values_for_chart = {}
    @sensors = Sensor.all.order( :id )

    @sensors.each do |s|
      values = s.sensor_observations.select( 'sensor_observations.observed_at, sensor_observations.value' ).where( [ 'sensor_observations.observed_at >= ?', 24.hours.ago ] ).collect{ |so|

        if s.ds1820? || s.dp?
          [so.observed_at, c_to_f( so.value )]
        else
          [so.observed_at,so.value]
        end
      }

      @values_for_chart[s.id] = moving_average_of_values( values )
    end

  end

  def record_observation
    @sensor = Sensor.find( params[:id] )

    @sensor.sensor_observations.create( { value: params[:value], observed_at: Time.now } )
    @sensor.update_attributes( { latest_value: params[:value], latest_value_observed_at: Time.now } )

    redirect_to @sensor
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
      format.html {
        @values_for_chart = {}

        values = @sensor.sensor_observations.select( 'sensor_observations.observed_at, sensor_observations.value' ).where( [ 'sensor_observations.observed_at >= ?', 24.hours.ago ] ).collect{ |so|

          if @sensor.ds1820?
            [so.observed_at, c_to_f( so.value )]
          else
            [so.observed_at,so.value]
          end
        }

        @values_for_chart[@sensor.id] = moving_average_of_values( values )

      }
      format.json {
        render :json => sensor_for_json
      }
    end
  end

  def historical_values
    @sensor = Sensor.find( params[:id] )

    if params[:s_ago].present?
      start = params[:s_ago].to_i.seconds.ago
    else
      start = 24.hours.ago
    end

    if params[:limit].present?
      limit = params[:limit]
    else
      limit = 600
    end

    values = @sensor.sensor_observations.select( 'sensor_observations.observed_at, sensor_observations.value' ).where( [ 'sensor_observations.observed_at >= ?', start ] ).order( "observed_at DESC" ).limit( limit )

    respond_to do |format|
      format.json {
        render :json => values
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
