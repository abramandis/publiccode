class RedZoneVShift < ApplicationRecord
  def self.load
    data = `**OMITTED** '\\copy (select "areaName", "dateTimeNearestHour", oee, "locationName" from v_shift) to STDOUT csv header'`
    csv_data = CSV.parse(data, headers: true)
    ActiveRecord::Base.transaction do
      RedZoneVShift.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('red_zone_v_shifts')
      csv_data.each {|row|
        RedZoneVShift.create(area_name: row["areaName"], date_time_nearest_hour: row["dateTimeNearestHour"], oee: row["oee"], location_name: row["locationName"])
      }
    end
  end
end
