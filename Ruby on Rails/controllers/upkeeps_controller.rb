class UpkeepsController < ApplicationController
  #Equipment Breakdown (Unplanned), Corrective Maintenance (Planned), Change Over (Planned), Safety, Project, Maintenance, Inspection, Facilities, Calibration, Damage, Electrical, 

  def index
    response = HTTParty.get("https://api.onupkeep.com/api/v2/work-orders?limit=12000&location=HmgXbjHrUR", :headers => {
      "Session-Token" => "**OMITTED**",
      "Content-Type" => "application/json" },
      timeout: 600)
    @data1 = JSON.parse(response.body)["results"]
    @data = []
    @data1.each do |data1|
      if data1["status"] == 'open'
        @data.prepend(data1)
      else
        @data.append(data1)
      end  
    end 
  end

  def line2
    response = HTTParty.get("https://api.onupkeep.com/api/v2/work-orders?limit=12000&location=GPoslfpYGp", :headers => {
      "Session-Token" => "**OMITTED**",
      "Content-Type" => "application/json" },
      timeout: 600)
    @data1 = JSON.parse(response.body)["results"]
    @data = []
    @data1.each do |data1|
      if data1["status"] == 'open'
        @data.prepend(data1)
      else
        @data.append(data1)
      end  
    end
  end

  def line3
    response = HTTParty.get("https://api.onupkeep.com/api/v2/work-orders?limit=12000&location=fKS6bKbkot", :headers => {
      "Session-Token" => "**OMITTED**",
      "Content-Type" => "application/json" },
      timeout: 600)
    @data1 = JSON.parse(response.body)["results"]
    @data = []
    @data1.each do |data1|
      if data1["status"] == 'open'
        @data.prepend(data1)
      else
        @data.append(data1)
      end  
    end
  end

  def line4
    response = HTTParty.get("https://api.onupkeep.com/api/v2/work-orders?limit=12000&location=crHwdyVF9A", :headers => {
      "Session-Token" => "**OMITTED**",
      "Content-Type" => "application/json" },
      timeout: 600)
    @data1 = JSON.parse(response.body)["results"]
    @data = []
    @data1.each do |data1|
      if data1["status"] == 'open'
        @data.prepend(data1)
      else
        @data.append(data1)
      end  
    end
  end

  def line5
    response = HTTParty.get("https://api.onupkeep.com/api/v2/work-orders?limit=12000&location=gtraAyH1Ee", :headers => {
      "Session-Token" => "**OMITTED**",
      "Content-Type" => "application/json" },
      timeout: 600)
    @data1 = JSON.parse(response.body)["results"]
    @data = []
    @data1.each do |data1|
      if data1["status"] == 'open'
        @data.prepend(data1)
      else
        @data.append(data1)
      end  
    end
  end
end
