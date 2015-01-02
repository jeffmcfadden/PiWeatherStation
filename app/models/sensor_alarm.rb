class SensorAlarm < ActiveRecord::Base
  belongs_to :sensor
  has_many :sensor_alarm_actions

  enum direction: [ :up, :down, :both ]

  scope :enabled, -> { where( enabled: true ) }

  def sensor_value_changed( previous_value: 0, new_value: 0 )
    if threshold_crossed?( previous_value: previous_value, new_value: new_value )
      self.sensor_alarm_actions.each do |saa|
        saa.fire!( previous_value: previous_value, new_value: new_value )
      end
    end
  end

  def threshold_crossed?( previous_value: 0, new_value: 0 )
    if previous_value != new_value
      if new_value < self.value && previous_value >= self.value && (self.down? || self.both?)
        true
      elsif new_value > self.value && previous_value <= self.value && (self.up? || self.both?)
        true
      else
        false
      end
    else
      false
    end
  end
end
