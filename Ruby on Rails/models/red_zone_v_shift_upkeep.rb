class RedZoneVShiftUpkeep < ApplicationRecord
  def self.load
    @initialized = true 
    data = `**OMITTED** \\copy (SELECT "areaName", "locationName", SUM("upSeconds") AS "totalUpSeconds" from v_shift GROUP BY "locationName", "areaName" ) to STDOUT csv header'`
    csv_data = CSV.parse(data, headers: true)
    ActiveRecord::Base.transaction do
      RedZoneVShiftUpkeep.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('red_zone_v_shift_upkeeps')
      csv_data.each {|row|
        RedZoneVShiftUpkeep.create(area_name: row["areaName"], location_name: row["locationName"], total_up_seconds: row["totalUpSeconds"], time: Time.now)
      }
    end
  end
end
