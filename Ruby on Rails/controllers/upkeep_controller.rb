class UpkeepController < ApplicationController

  def update_meters
    #initialize page showing current data
    @machineHours = RedzoneController.getMachineHours  
    @upkeepMeterReadings = getUpkeepMeterReadings
  end

  def sync_meter_data
    redzoneData = RedzoneController.syncDataForUpkeep #pulls redzone data 
    upkeepMeters = UpkeepMeters.load 
    if redzoneData && upkeepMeters && !upkeepMeters.empty?
      redzoneData.each do |row|
        area_name = row["areaName"]
        location_name = row["locationName"]
        up_hours = row["totalUpSeconds"].to_i/60
        
        meter = upkeepMeters.detect { |m| m["name"] == location_name } #find matching meter in Upkeep 
        if meter
          UpkeepMeters.updateMeterReading(meter, up_hours)
          puts "*****Meter Found and Updated*****"
        else 
          puts "*****No Matching meter Found*****" 
        end 

      end 

      if request.present? && request.format.html? 
        redirect_to action: :update_meters 
      end

    else
      puts "*****Could Not Fetch Data from either Redzone or Upkeep*****" 
    end 

  end 

  private

  def getUpkeepMeterReadings
    begin
      upkeepMeters = UpkeepMeters.load
      readings = []
      upkeepMeters.each do |meter|
        reading = UpkeepMeters.getMeterReading(meter)
        readings << reading if reading
      end
      return readings
    rescue StandardError => e
      puts "*****Error occurred while retrieving upkeep meter readings: #{e.message}*****"
      return []
    end
  end
end 