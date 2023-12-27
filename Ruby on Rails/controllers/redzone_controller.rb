require 'pp' 
require 'csv' 

class RedzoneController < ApplicationController
 
  SELECTED_COLUMNS = [:internal_id, :name, :material_type]
  SELECTED_COLUMNS1 = [:internal_id, :name, :material_type, :conversions]
  SELECTED_COLUMNS2 = [:output_product, :input_product, :qty]
  MATERIAL_TYPES = [:FG_POWDER, :FG_CAPSULES, :FG_TABLETS, :FG_STICKPACK, :FG_SACHET, :FG_BAG, :FG_OTHERS, :SFG, :SFG_BLENDING, :SFG_ENCAPSULATING, :SFG_TABLETTING, :SFG_TABLETCOATING]
  MANUFACTURING_TYPES = [:Packaging, :Other, :Blending, :Encapsulating, :Tabletting, :Coating]
  LOCATION_NAMES = [
    'Bin Blender',
    'Blender Munson',
    'Blender Ribbon 1',
    'Blender Ribbon 2',
    'V-Blender 1',
    'V-Blender 2',
    'Coating Machine 1',
    'Encap Room 1 (Bosch 4D)',
    'Encap Room 2 (Bosch 3C)',
    'Encap Room 3 (DMW 2000)',
    'Encap Room 4 (Bosch 2B)',
    'Encap Room 5 (Index 1500)',
    'Encap Room 6 (Model 10)',
    'Encap Room 7 (Index 2B)',
    'Encap Room 8 (Bosch 1A)',
    'Encap Room 9 (Kikusui)',
    'Encap Room 10 (Index 5E)',
    'Encap Room 11 (Syntegon 3005-1)',
    'Encap Room 12 (Syntegon 3005-2)',
    'Encap Room 13',
    'Bagger',
    'Sachet',
    'Stick Pack 4-Lane',
    'Stick Pack 6-Lane',
    'Packaging Line 1',
    'Packaging Line 2',
    'Packaging Line 3',
    'Packaging Line 4',
    'Packaging Line 5',
    'Tablet Press DD2',
    'Tablet Press D3',
    'Tablet Press BB2',
    'Tablet Press Kikusui]'
  ]
  UOMBYCATEGORY = { 
    :FG_POWDER => :Each, 
    :FG_CAPSULES => :Each, 
    :FG_TABLETS => :Each,  
    :FG_STICKPACK => :Each,
    :FG_SACHET => :Each,
    :FG_BAG => :Each,
    :FG_OTHERS => :Each, 
    :SFG => :Kg, 
    :SFG_BLENDING => :Kg, 
    :SFG_ENCAPSULATING => :Each, 
    :SFG_TABLETTING => :Each, 
    :SFG_TABLETCOATING => :Each 
  }

  RUNRATEBYCATEGORY = { 
    :FG_POWDER => 40, 
    :FG_CAPSULES => 80, 
    :FG_TABLETS => 80,  
    :FG_STICKPACK => 36,
    :FG_SACHET => 60,
    :FG_BAG => 30,
    :FG_OTHERS => 60, 
    :SFG => 11, 
    :SFG_BLENDING => 11, 
    :SFG_ENCAPSULATING => 3000, 
    :SFG_TABLETTING => 1700, 
    :SFG_TABLETCOATING => 1 
  }

  WEIGHTORCOUNT = { 
    :FG_POWDER => :BYWEIGHT,
    :FG_CAPSULES => :BYCOUNT, 
    :FG_TABLETS => :BYCOUNT,  
    :FG_STICKPACK => :BYWEIGHT,
    :FG_SACHET => :BYWEIGHT,
    :FG_BAG => :BYWEIGHT,
    :FG_OTHERS => :BYWEIGHT, 
    :SFG => :BYWEIGHT, 
    :SFG_BLENDING => :BYWEIGHT, 
    :SFG_ENCAPSULATING => :BYWEIGHT, 
    :SFG_TABLETTING => :BYWEIGHT, 
    :SFG_TABLETCOATING => :BYWEIGHT 
  }

  RANGERATES = { 
    :FG_POWDER => [[150,30],[450,28],[800,28],[1100,20],[10000,17]],
    :FG_CAPSULES => [[40,80],[60,75],[90,60],[130,40],[180,35],[500,30],[10000,30]],
    :FG_TABLETS => [[40,80],[60,75],[90,60],[130,40],[180,35],[500,30],[10000,30]],
    :FG_STICKPACK => [[1000,36],[10000,36]],
    :FG_SACHET => [[1000,60],[10000,60]],
    :FG_BAG => [[1000,30], [10000,30]],
    :FG_OTHERS => [],
    :SFG => [[800,22],[5000,11]], 
    :SFG_BLENDING => [[800,22],[5000,11]], 
    :SFG_ENCAPSULATING => [], 
    :SFG_TABLETTING => [], 
    :SFG_TABLETCOATING => [] 
  }

  NUMBEROFLOCATIONS = {
    :FG_POWDER => 5, 
    :FG_CAPSULES => 5, 
    :FG_TABLETS => 5,  
    :FG_STICKPACK => 2,
    :FG_SACHET => 1,
    :FG_BAG => 4,
    :FG_OTHERS => 9, 
    #:SFG => 1,
    :SFG_BLENDING => 6, 
    :SFG_ENCAPSULATING => 10, 
    :SFG_TABLETTING => 4, 
    :SFG_TABLETCOATING => 1 
  }

  LOCATIONNAMESANDRATES = {
    :SFG_TABLETTING_LR1 => ["Tablet Press DDS", "Tabletting", 720, "Each"],
    :SFG_TABLETTING_LR2 => ["Encap Room 10 (Stokes RD3)", "Tabletting", 720, "Each"],
    :SFG_TABLETTING_LR3 => ["Tablet Press BB2", "Tabletting", 720, "Each"],
    :SFG_TABLETTING_LR4 => ["Encap Room 9 (Kikusui)", "Tabletting", 720, "Each"],

    :FG_POWDER_LR1 => ["Packaging Line 1", "Packaging", 40, "Each"], 
    :FG_POWDER_LR2 => ["Packaging Line 2", "Packaging", 40, "Each"],
    :FG_POWDER_LR3 => ["Packaging Line 3", "Packaging", 40, "Each"],
    :FG_POWDER_LR4 => ["Packaging Line 4", "Packaging", 40, "Each"],
    :FG_POWDER_LR5 => ["Packaging Line 5", "Packaging", 40, "Each"],

    :FG_CAPSULES_LR1 => ["Packaging Line 1", "Packaging", 80, "Each"], 
    :FG_CAPSULES_LR2 => ["Packaging Line 2", "Packaging", 80, "Each"], 
    :FG_CAPSULES_LR3 => ["Packaging Line 3", "Packaging", 80, "Each"], 
    :FG_CAPSULES_LR4 => ["Packaging Line 4", "Packaging", 80, "Each"], 
    :FG_CAPSULES_LR5 => ["Packaging Line 5", "Packaging", 80, "Each"], 

    :FG_TABLETS_LR1 => ["Packaging Line 1", "Packaging", 80, "Each"], 
    :FG_TABLETS_LR2 => ["Packaging Line 2", "Packaging", 80, "Each"], 
    :FG_TABLETS_LR3 => ["Packaging Line 3", "Packaging", 80, "Each"], 
    :FG_TABLETS_LR4 => ["Packaging Line 4", "Packaging", 80, "Each"], 
    :FG_TABLETS_LR5 => ["Packaging Line 5", "Packaging", 80, "Each"], 

    :FG_OTHERS_LR1 => ["Packaging Line 1", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR2 => ["Packaging Line 2", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR3 => ["Packaging Line 3", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR4 => ["Packaging Line 4", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR5 => ["Packaging Line 5", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR6 => ["Stick Pack 4-Lane", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR7 => ["Stick Pack 6-Lane", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR8 => ["Sachet", "Packaging", 61, "Each"], 
    :FG_OTHERS_LR9 => ["Bagger", "Packaging", 61, "Each"], 

    :SFG_ENCAPSULATING_LR1 => ["Encap Room 1 (Bosch 4D)", "Encapsulating", 1500, "Each"],
    :SFG_ENCAPSULATING_LR2 => ["Encap Room 2 (Bosch 3C)", "Encapsulating", 1500, "Each"],
    :SFG_ENCAPSULATING_LR3 => ["Encap Room 3 (DMW 2000)", "Encapsulating", 2000, "Each"],
    :SFG_ENCAPSULATING_LR4 => ["Encap Room 4 (Bosch 2B)", "Encapsulating", 1500, "Each"],
    :SFG_ENCAPSULATING_LR5 => ["Encap Room 5 (Index 1500)", "Encapsulating", 1500, "Each"],
    :SFG_ENCAPSULATING_LR6 => ["Encap Room 6 (Polishing)", "Encapsulating", 416, "Each"],
    :SFG_ENCAPSULATING_LR7 => ["Encap Room 7 (Index 2B)", "Encapsulating", 1500, "Each"],
    :SFG_ENCAPSULATING_LR8 => ["Encap Room 8 (Bosch 1A)", "Encapsulating", 1500, "Each"],
    #Room 9,10 here are turned into tabletting rooms now
    :SFG_ENCAPSULATING_LR9 => ["Encap Room 11 (Syntegon 3005-1)", "Encapsulating", 3000, "Each"],
    :SFG_ENCAPSULATING_LR10 => ["Encap Room 12 (Syntegon 3005-2)", "Encapsulating", 3000, "Each"],

    :SFG_BLENDING_LR1 => ["Bin Blender", "Blending", 11, "Kg"], 
    :SFG_BLENDING_LR2 => ["Blender Munson", "Blending", 11, "Kg"], 
    :SFG_BLENDING_LR3 => ["Blender Ribbon 1", "Blending", 11, "Kg"], 
    :SFG_BLENDING_LR4 => ["Blender Ribbon 2", "Blending", 11, "Kg"], 
    :SFG_BLENDING_LR5 => ["V-Blender 1", "Blending", 11, "Kg"], 
    :SFG_BLENDING_LR6 => ["V-Blender 2", "Blending", 11, "Kg"], 

    :FG_SACHET_LR1 => ["Sachet", "Packaging", 60, "Each"], 

    :FG_STICKPACK_LR1 => ["Stick Pack 4-Lane", "Packaging", 40, "Each"], 
    :FG_STICKPACK_LR2 => ["Stick Pack 6-Lane", "Packaging", 60, "Each"], 

    :FG_BAG_LR1 => ["Bagger", "Packaging", 30, "Each"], 
    :FG_BAG_LR2 => ["Packaging Line 1", "Packaging", 30, "Each"], 
    :FG_BAG_LR3 => ["Packaging Line 2", "Packaging", 30, "Each"], 
    :FG_BAG_LR4 => ["Packaging Line 3", "Packaging", 30, "Each"], 

    :SFG_TABLETCOATING_LR1 => ["Coater", "Tabletting", 1, "Kg"], 

  }

  SEGMENTSTABLE = {
    :SFG_ENCAPSULATING_S1 => [1, "1500Segment", 12, "Each"],
    :SFG_ENCAPSULATING_S2 => [1,	"2000Segment",	16,	"Each"],
    :SFG_ENCAPSULATING_S3 => [1, "ZanasiSegment", 10, "Each"],
    :SFG_ENCAPSULATING_S4 => [1, "K40iSegment", 5, "Each"],
    :SFG_ENCAPSULATING_S5 => [1, "3005Segment", 21, "Each"],
    :FG_STICKPACK_S1 => [1, "Stick4Cycle", 4, "Each"],
    :FG_STICKPACK_S2 => [1, "Stick6Cycle", 6, "Each"],
    :SFG_TABLETTING_S1 => [1, "BB2Cycle", 54, "Each"],
    :SFG_TABLETTING_S2 => [1, "D3Cycle", 16, "Each"],
    :SFG_TABLETTING_S3 => [1, "DD2Cycle", 46, "Each"],
    :SFG_TABLETTING_S4 => [1, "KikiCycle", 29, "Each"]
  }

  NUMBEROFSEGMENTS = {
    :SFG_ENCAPSULATING => 5, 
    :SFG_TABLETTING => 4,
    :FG_STICKPACK => 2
  }

  @all_product_codes = Set.new 
  @sfg_conversions = Set.new
  @sfg_weights = Set.new
  @fg_sfg_quantities = Set.new
  @all_location_rates = []
  @all_locations_data = []
  @all_segments_data = []
  @dataFetchError = true 

  #region View Controllers 
  #tag create_new_products
  def create_new_products
    run_rate_inputs = params[:changes] ? JSON.parse(params[:changes]) : nil
    #convert the parsed values into numbers
    #run_rate_inputs = run_rate_inputs&.map { |item| item&.map { |value| value&.to_f } }
    
    
    @all_product_codes = SapMaterial.where(material_type: MATERIAL_TYPES).pluck(*SELECTED_COLUMNS).to_set
    @sfg_conversions = SapMaterial.where(material_type: 'SFG').pluck(*SELECTED_COLUMNS1).to_set
    @sfg_weights = Set.new(@sfg_conversions.map do |item| #extract product weights from data 
      [
        item[0],
        item[1],
        item[2], 
        item[3].find { |conversion| conversion["quantity_uom"] == "E27" }&.fetch("corresponding_quantity")&.to_f
      ]
      end)
    @fg_sfg_quantities = SapBomItem.where(unit: 'E27').pluck(*SELECTED_COLUMNS2).to_set #sfg/fg relationships + count/quantities 
    
    puts "Run Rate Inputs: #{run_rate_inputs}"
    
    if @all_product_codes && @sfg_conversions && @sfg_weights 
      @dataFetchError = false
      addManufacturingType
      addUOM
      addQuantity
      addTotalGrams
      addWeightOrCount
      consolidateProductCountOrGrams
      addDefaultRunRates
      addRunRatesByRanges
      #addRedZoneActualRunRates
      addManualRateChanges(run_rate_inputs)
      fetchManualRateChanges
      overrideRunRatesManually 
      addRedzoneSyncCommand
    
    else 
      @dataFetchError = true 
      puts "***** SapMaterial or SapBomItem Data not returned properly. *****"
    end 
    
  end 

  #tag location_rates
  def location_rates 
    create_new_products
    reducedArray = []
    duplicated_data = []
    indices_to_select = [0, 1, 3, 10]
    
    if @dataFetchError == false 
      @all_product_codes.each do |row|
        newRow = row.values_at(*indices_to_select).dup
        reducedArray << newRow
      end 

      #multiply rows by number of locations 
      reducedArray.each do |row|
        symbol = row[2].to_sym
        NUMBEROFLOCATIONS[symbol].times do |i|
          newLocationName = row[2] + "_LR" + (i + 1).to_s 
          newRow = row.dup
          newRow << newLocationName
          duplicated_data << newRow
        end 
      end  

      #add location name and location rate to each duplicated row 
      nilCount = 0
      nilLocationData = 0
      duplicated_data.each do |row|
        if row.nil? 
          nilCount += 1 
        else 
          locationData = LOCATIONNAMESANDRATES[row[4].to_sym]
          if !locationData.nil? 
            row << locationData[1] #location area
            row << locationData[0] #location name  
            case locationData[1]
            when "Encapsulating", "Tabletting", "Blending"
              row << locationData[2] #location runrate
            when "Packaging"
              if locationData[0] == "Stick Pack 4-Lane" || locationData[0] == "Stick Pack 6-Lane" 
                row << locationData[2] 
              else
                row << row[3].dup #run rate calculated during 'create_new_products' 
              end 
            else 
              row << row[3].dup 
            end 
          else 
            nilLocationData += 1 
            puts "NIL LOCATION DATA FOUND: ", row 
          end 
        end 
      end 
      puts "Total Duplicated Row Count: ", duplicated_data.count 
      puts "Validated Row Count: ", validate_row_count  
      puts "NIL COUNT: ", nilCount 
      puts "NIL LOCATION DATA: ", nilLocationData
      @all_locations_data = duplicated_data 
      addSyncCommandLocations 
    else 
      puts "***** DATA NOT RETURNED CORRECTLY *****"
    end 
  end 

  #tag segments 
  def segments 
    create_new_products
    reducedArray = []
    duplicated_data = []
    indices_to_select = [0, 1, 3]

    if @dataFetchError == false
      @all_product_codes.each do |row|
        if row[3] == "SFG_ENCAPSULATING" || row[3] == "SFG_TABLETTING" || row[3] == "FG_STICKPACK"
          reducedArray << row.values_at(*indices_to_select).dup 
        end  
      end
    
      #dup rows by number of segments 
      reducedArray.each do |row|
        skey = row[2].to_sym
        NUMBEROFSEGMENTS[skey].times do |i|
          repeatName = skey.to_s + "_S" + (i + 1).to_s 
          segmentData = SEGMENTSTABLE[repeatName.to_sym]
          fromValue = segmentData[0]
          segmentName = segmentData[1]
          toValue = segmentData[2]
          unitOfMeasure = segmentData[3]
          newRow = row.dup 
          newRow << repeatName
          newRow << fromValue
          newRow << segmentName 
          newRow << toValue 
          newRow << unitOfMeasure
          duplicated_data << newRow 
        end 
      end 
      @all_segments_data = duplicated_data 
      addSyncCommandSegments 
    else 
      puts "***** DATA NOT RETURNED CORRECTLY *****"
    end 
  end 

  #endregion #END VIEW CONTROLLERS

  #region Functions 
  def addManualRateChanges(run_rate_inputs) 
    if run_rate_inputs.nil?
      puts "No changes detected."
    else
      #adds new rate changes to the database 
      RedZoneManualRateChange.add_changes(run_rate_inputs)
    end
  end

  def fetchManualRateChanges
    #gets rate changes from the database and adds them to row[11]
    manualRateChanges = RedZoneManualRateChange.all
    if manualRateChanges.any?
      manualRateChanges.each do |row|
        sku = row["sku"]
        rate = row["rate"]
        @all_product_codes.each do |row|
          if row[0] == sku
            row << rate
          end
        end
      end
    else
      puts "No manual rate changes found."
    end
  end

  def overrideRunRatesManually
    #manually override run rates for specific products and adds them to row[12]
    @all_product_codes.each do |row|
      if row[11] != 0 && !row[11].nil?
        row << row[11]
      elsif row[11] == 0
        row << row[10]
        row[11] = ""
      else 
        row << ""
        row << row[10]
      end  
    end 
  end 


  def addManufacturingType 
    @all_product_codes.each do |row|
      if row[2] == "SFG"
        if row[0].end_with?("-CAP")
          row << MATERIAL_TYPES[9].to_s
        elsif row[0].end_with?("-TAB")
          row << MATERIAL_TYPES[10].to_s
        elsif row[0].end_with?("-TAB-COAT")
          row << MATERIAL_TYPES[11].to_s
        else
          row << MATERIAL_TYPES[8].to_s
        end 
      else 
        row << row[2]
      end 
    end 
  end 

  def addUOM
    @all_product_codes.each do |row|
      row << UOMBYCATEGORY[row[3].to_sym].to_s
    end 
  end 

  def addQuantity
    @all_product_codes.each do |row|
      match_string = row[0]
      if row[3].start_with?("FG")
        matchFound = false 
        @fg_sfg_quantities.each do |each| 
          if each[0] == match_string
            row << each[2] #adds quantity
            matchFound = true 
          end 
        end
        if matchFound == false 
          row << "" #FG NOT found in the fg_sfg_quantity table 
        end 
      else row << "" #if it's not an FG    
      end 
    end
  end 

  def addTotalGrams
    @all_product_codes.each do |row|
      matchFound = false 
      if row[3].start_with?("FG") 
        corresponding_sfg = findCorresponding(row[0])
        if corresponding_sfg.is_a?(String) && !corresponding_sfg.empty? 
          @sfg_weights.each do |each|
            if each[0] == corresponding_sfg.to_s 
              matchFound = true 
              weightInGramsPerServing = convertMgToGrams(each[3])
              totalWeight = weightInGramsPerServing * row[5] #weight x quantity 
              row << totalWeight
            end 
          end 
        end 
        if matchFound == false 
          row << "" 
        end 
      else row << "" 
      end 

    end 
  end 

  def findCorresponding(codeToMatch)
    @fg_sfg_quantities.each do |row|
      if codeToMatch == row[0]
        return row[1]
      end 
    end 
  end 

  def convertMgToGrams(item)
    tempGrams = item/1000
    return tempGrams.floor(2)
  end

  def addWeightOrCount
    @all_product_codes.each do |row| 
      row << WEIGHTORCOUNT[row[3].to_sym].to_s
    end 
  end 

  def consolidateProductCountOrGrams
    @all_product_codes.each do |row|
      if row[7] == "BYCOUNT"
        row << row[5]
      elsif row[7] == "BYWEIGHT"
        row << row[6]
      else 
        row << ""
      end 
    end 
  end 

  def addDefaultRunRates
    @all_product_codes.each do |row|
      row << RUNRATEBYCATEGORY[row[3].to_sym]
    end 
  end 

  def addRunRatesByRanges 
    @all_product_codes.each do |row|
      weightOrCount = row[8].to_f
      previousRunRange = [0, 0]
      newRunRate = 0 
      rangeRunRates = RANGERATES[row[3].to_sym]
      rangeRunRates.each do |range|
        if !weightOrCount.nil?  
          if weightOrCount.to_f <= range[0].to_f && weightOrCount > previousRunRange[0].to_f
            newRunRate = range[1].to_f
          end 
          previousRunRange = range 
        end 
      end 
      if newRunRate != 0 && !newRunRate.nil? 
        row << newRunRate
      else 
        row << row[9]
      end
    end 
  end 
  
  def validate_row_count 
    validatedRowCount = 0 
    @all_product_codes.each do |row|
      validatedRowCount += 1 * NUMBEROFLOCATIONS[row[3].to_sym]
    end 
    return validatedRowCount 
  end 

  def addRedzoneSyncCommand
    @all_product_codes.each do |row|
      row << "SYNC"
    end 
  end 

  def addSyncCommandLocations
    @all_locations_data.each do |row|
      row << "SYNC" 
    end 
  end 

  def addSyncCommandSegments 
    @all_segments_data.each do |row|
      row << "SYNC"
    end 
  end 

  def generate_all_products_csv 
    create_new_products
    if @dataFetchError == false
      respond_to do |format|
        format.csv {
          data = CSV.generate do |csv|
            csv << ["command", "manufacturingType", "SKU", "name", "ratePerMinute", "unitOfMeasure", "overheadCostPerUnit", "materialCostPerUnit", "labelWeight", "targetOEE", "exteralID"]
            @all_product_codes.each {|row|
              indices = [13, 3, 0, 1, 12, 4]
              csv << row.values_at(*indices)
            }
          end
          current_datetime = Time.now.strftime("%m-%d-%Y")
          count = @all_product_codes.count.to_s 
          csvFileName = current_datetime + "_" + count + "_products.csv"
          send_data data, filename: csvFileName
        }
      end 
    else 
      puts "***** Could not generate CSV *****"
    end
  end 

  def generate_location_rates_csv
    location_rates
    if @dataFetchError == false 
      respond_to do |format|
        format.csv {
          data = CSV.generate do |csv|
            csv << ["command", "SKU", "name", "locationName", "locationRatePerMinute"]
            @all_locations_data.each {|row|
              indices = [8, 0, 1, 6, 7]
              csv << row.values_at(*indices) 
            }
          end
          current_datetime = Time.now.strftime("%m-%d-%Y")
          count = @all_locations_data.count.to_s 
          csvFileName = current_datetime + "_" + count + "_locationrates.csv" 
          send_data data, filename: csvFileName
        }
      end
    else 
      puts "***** Could not generate CSV *****"
    end 
  end 

  def generate_segments_csv
    segments
    if @dataFetchError == false 
      respond_to do |format|
        format.csv {
          data = CSV.generate do |csv|
            csv << ["command", "SKU", "name", "fromValue", "fromUnitOfMeasure", "toValue", "toUnitOfMeasure"]
            @all_segments_data.each {|row|
              indices = [8, 0, 1, 4, 5, 6, 7]
              csv << row.values_at(*indices) 
            }
          end
          current_datetime = Time.now.strftime("%m-%d-%Y")
          count = @all_segments_data.count.to_s 
          csvFileName = current_datetime + "_" + count + "_unitconversions.csv"
          send_data data, filename: csvFileName
        }
      end
    else 
      puts "***** Could not generate CSV *****"
    end 
  end 
  #endregion Functions 

  ### BEGIN REDZONE/UPKEEP SYNC FUNCTIONS ### 
  def self.getMachineHours 
    machine_hours = RedZoneVShiftUpkeep.all 
    if machine_hours.any? 
      return machine_hours
    else 
      puts "!!!!!! NO RECORDS FOUND !!!!!!!"
      return []
    end 
  end

  def self.syncDataForUpkeep
    return RedZoneVShiftUpkeep.load
  end 
  ###endregion END REDZONE/UPKEEP SYNC FUNCTIONS ### 
end 
