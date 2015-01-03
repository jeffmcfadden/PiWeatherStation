class SensorAlarmAction < ActiveRecord::Base
  belongs_to :sensor_alarm

  enum action_type: [ :twitter ]

  serialize :params, JSON

  def fire!( previous_value: 0, new_value: 0 )
    if self.twitter?
      self.fire_twitter!( previous_value: previous_value, new_value: new_value )
    else
      Rails.logger.warn "I don't know how to fire an alarm of type #{self.action_type}"
    end
  end

  def fire_twitter!( previous_value: 0, new_value: 0 )
    Rails.logger.debug "Firing twitter! New value is #{new_value}"

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = self.params["consumer_key"]
      config.consumer_secret     = self.params["consumer_secret"]
      config.access_token        = self.params["access_token"]
      config.access_token_secret = self.params["access_token_secret"]
    end

    new_value_f = (new_value * 1.8 + 32.00).round(2)

    client.update( self.params["message"].gsub( "$new_value", new_value_f.to_s ).gsub( "$time", Time.now.to_s ) )
  end
end
