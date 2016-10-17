class Airport < ApplicationRecord
  has_many :runways

  def get_data
    api_key = ENV["WU_KEY"]

    current_weather = HTTParty.get("http://api.wunderground.com/api/" + api_key +
                      "/conditions/q/" + self.symbol + ".json")

    forecast = HTTParty.get("http://api.wunderground.com/api/" + api_key +
                      "/hourly/q/" + self.symbol + ".json")

    ret_object = {}
    ret_object["time"] = [current_weather["current_observation"]["observation_time"]]
    ret_object["runways"] = {}

    current_degrees = current_weather["current_observation"]["wind_degrees"]
    current_wind_speed = (current_weather["current_observation"]["wind_mph"].to_i / 1.15).round

    ret_object["wind_direction"] = [current_degrees]
    ret_object["wind_speed"] = [current_wind_speed]

    test_runways = self.runways
    test_runways.each do |runway|
      ret_object["runways"][runway.id] = []
      time_obj = {}
      time_obj["time"] = current_weather["current_observation"]["observation_time"]
      time_obj["wind_direction"] = current_degrees
      time_obj["wind_speed"] = current_wind_speed
      runway_number = runway.number.to_i * 10
      angle = (runway_number - current_degrees)
      radians = angle * Math::PI / 180

      crosswind = current_wind_speed * Math.sin(radians)
      headwind = current_wind_speed * Math.cos(radians)
      puts "OG CALCULATIONS"
      puts runway_number
      puts current_degrees
      puts current_wind_speed
      puts angle
      puts crosswind
      puts headwind


      time_obj["crosswind"] = crosswind.abs.round
      time_obj["headwind"] = headwind.round


      ret_object["runways"][runway.id].push(time_obj)

      forecast["hourly_forecast"].each do | hourly_fc |
        fcst_obj = {}
        wind_direction = hourly_fc["wdir"]["degrees"]
        wind_speed = (hourly_fc["wspd"]["english"].to_i / 1.15).round
        fcst_obj["time"] = hourly_fc["FCTTIME"]["civil"]
        ret_object["time"].push(fcst_obj["time"])
        fcst_obj["wind_direction"] = wind_direction
        fcst_obj["wind_speed"] = wind_speed
        ret_object["wind_direction"].push(wind_direction)
        ret_object["wind_speed"].push(wind_speed)

        angle = (runway_number - wind_direction.to_i)
        radians = angle * Math::PI / 180
        crosswind = wind_speed * Math.sin(radians)
        headwind = wind_speed * Math.cos(radians)

        puts "HOURLY CALCULATIONS"
        puts "RUNWAY NUMBER: " + runway_number.to_s
        puts "WIND DIRECTION: " + wind_direction.to_s
        puts "WIND SPEED: " + wind_speed.to_s
        puts "ANGLE: " + angle.to_s
        puts "RADIANS: " + radians.to_s
        puts "SIN(angle): " + Math.sin(angle).to_s
        puts "SIN(radians): " + Math.sin(radians).to_s
        puts "CROSSWIND: " + crosswind.to_s
        puts "HEADWIND: " + headwind.to_s


        fcst_obj["crosswind"] = crosswind.abs.round
        fcst_obj["headwind"] = headwind.round

        ret_object["runways"][runway.id].push(fcst_obj)


      end

    end

    ret_object["time"].uniq!

    return ret_object

  end
end
