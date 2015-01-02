class SensorsController < ApplicationController

  def index
  end

  def take_sensor_observations
    Sensor.all.each do |s|
      s.take_observation!
    end

    render json: { "ok" => "ok" }
  end

end
