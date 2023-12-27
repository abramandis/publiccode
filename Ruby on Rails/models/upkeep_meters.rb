class UpkeepMeters < ApplicationRecord 

  @upkeepSessionToken = "**"
  @upkeepSessionTokenExpiry = "**"
   
  def self.load
    begin
      response = HTTParty.get("https://api.onupkeep.com/api/v2/meters/", :headers => {
        "Session-Token" => @upkeepSessionToken,
        "Content-Type" => "application/json" },
        timeout: 600)
      
      if response.success?
        return JSON.parse(response.body)["results"]
      else
        puts "HTTP request failed with status code: #{response.code}"
        puts "Response body: #{response.body}"
        return []  # Return an empty array or handle the error case as appropriate
      end
    rescue HTTParty::Error, StandardError => e
      puts "An error occurred: #{e}"
      return []  # Return an empty array or handle the error case as appropriate
    end
  end 

  def self.getMeterReading(nameOfMeter)
    meter_id = nameOfMeter["id"]
    uri = "https://api.onupkeep.com/api/v2/meters/#{meter_id}/readings"
    response = HTTParty.get(uri, :headers => {
      "Session-Token" => @upkeepSessionToken,
      "Content-Type" => "application/json" },
      timeout: 600)
    return JSON.parse(response.body)["results"]
  end 

  def self.updateMeterReading(meter, reading)
    uri = "https://api.onupkeep.com/api/v2/meters/#{meter['id']}/readings"
    response = HTTParty.post(uri, {
      headers: {
      "Session-Token" => @upkeepSessionToken,
      "Content-Type" => "application/json",
      },
    body: {
      value: (reading),
    }.to_json
    })
    if response.code.to_i >= 200 && response.code.to_i < 300
      #HTTP was Success
    else 
      #HTTP was Failed 
    end
  end 
end 



