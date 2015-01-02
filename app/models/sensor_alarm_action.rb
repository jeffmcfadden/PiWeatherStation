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
  end
end
