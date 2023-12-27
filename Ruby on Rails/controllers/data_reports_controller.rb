# Misc Data and Reports Controller 
require 'pp' 
require 'csv'
require 'date'

class DataReportsController < ApplicationController

    #========================================================================
    #region View Controllers 
    #========================================================================
    
    #tag run_quantities 
    def run_quantities 
        @page_title = "Run Quantities"
        #report to show run quantities and material breakouts for production orders over a set period of time. 
        #this report will also detail what the current total demand moving forward for these prodcuts and materials are.
        @data_by_po_id = {}
        @all_data = []
        @dataFetchError = true  

        all_status = ["In Preparation", "Released", "Started", "Finished"]
        #these need to be environment variables or stored somewhere centrally, consider doing any product that start with "FG" 
        product_types = ["FG_OTHERS", "FG_POWDER", "FG_CAPSULES", "FG_TABLETS", "FG_BAG", "FG_SACHET", "FG_STICKPACK"] 
        dateRange = 12
        today = Date.current

        all_pos = SapProductOrder.eager_load(:sap_production_order_input_products)
          .where("sap_product_orders.status in (?)", all_status)
          .where("sap_product_orders.product_type in (?)", product_types)
          .where("latest_end >= ?", (today - dateRange.months))

        # create associated component data 
        all_pos.each do |sap_product_order|
          po_id = sap_product_order.po_id
          @data_by_po_id[po_id] = sap_product_order.sap_production_order_input_products.dup
        end

        if all_pos
          @all_data = all_pos.dup  
          @dataFetchError = false 
        else 
          puts "*** all_pos nil ***"
        end 
    end 
    
    #tag production_targets
    def production_targets
      
    end 

    #tag shipping_targets
    def shipping_targets(date = nil, target = nil)
      @page_title = "Shipping Targets"
      @work_saturdays = false 
      @cur_date = params[:selected_date] ? Date.strptime(params[:selected_date], "%m-%Y") : Date.current
      @shipping_target = params[:shipping_target] ? params[:shipping_target].to_i : 9999
      
      month_number = @cur_date.month
      year = @cur_date.year
      current_date = Date.today 
      
      month_names = Date::MONTHNAMES.compact
      @month_name = month_names[month_number - 1]
      @year = year 
      @day_names = Date::DAYNAMES
      @all_day_names = get_all_day_names_in_month(year, month_number) 
      
      current_day_number = current_date.wday
      current_date_day = current_date.day   
      @days_in_month = Date.new(year, month_number, -1).day
      start_date = Date.new(year, month_number, 1)
      end_date = Date.new(year, month_number, -1)
      
      #calculate working days 
      @working_days = 0 
      
      if @work_saturdays then @working_days = (start_date..end_date).count { |date| (1..6).cover?(date.wday) } 
      else @working_days = (start_date..end_date).count { |date| (1..5).cover?(date.wday) } 
      end 

      #calculate daily targets
      @daily_target = @shipping_target / @working_days 
      @daily_targets = calculate_daily_targets(@daily_target, @work_saturdays)
      @daily_cumulative_targets = get_cumulative(@daily_targets) 

      #get daily actuals and create daily actuals array 
      actuals_data = get_actuals(year, month_number) 
      @daily_actuals = []
      (1..@days_in_month).each do |date_day|
        date = Date.new(year, month_number, date_day)
        if actuals_data[date] && actuals_data[date].present? && !actuals_data[date].empty? 
          @daily_actuals << actuals_data[date]&.sum{|x|x.sales_order_value} || 0 
        else 
          @daily_actuals << 0 
        end 
      end 
      @daily_cumulative_actuals = get_cumulative(@daily_actuals) 
  
      #get daily planned shipouts 
      @daily_planned = get_planned_deliveries(year, month_number) 
      @daily_planned = replace_previous_with_actuals(year, month_number, @daily_actuals, @daily_planned)
      @daily_cumulative_planned = get_cumulative(@daily_planned)
    end 
     
    #========================================================================
    #endregion
    #========================================================================
    #region Functions 
    #========================================================================
    
    def get_all_day_names_in_month(year, month_number) 
      start_date = Date.new(year, month_number, 1)
      end_date = Date.new(year, month_number, -1)
      return (start_date..end_date).map { |date| date.strftime('%A') }
    end 

    def calculate_daily_targets(daily_target, work_saturdays)
      targets_array = []
      (1..@days_in_month).each do |day_number|
        day_name = @all_day_names[day_number - 1]
        if (day_name == "Saturday") && !work_saturdays
          targets_array << 0 
        elsif day_name == "Sunday" 
          targets_array << 0 
        else #it's a working day 
          targets_array << daily_target 
        end 
      end 
      return targets_array 
    end 

    def get_actuals(year, month_number)
      #returns all ODI's within the first of the month and the current date. 
      start_date = Date.new(year, month_number, 1)
      end_date = Date.new(year, month_number, -1)
      if Date.current > start_date && Date.current < end_date
        end_date = Date.current
      end 
      outbound_delivery_items = SapOutboundDeliveryItem.where("delivery_date >= ? and delivery_date <= ?", start_date.at_beginning_of_day, end_date.at_end_of_day)
      
      outbound_delivery_items = outbound_delivery_items.group_by{|x|
        dd = x.delivery_date.to_date
        dd -= 2.days if dd.wday == 0
        dd -= 1.day if dd.wday == 6
        dd 
      }
      return outbound_delivery_items
    end 

    def get_planned_deliveries(year, month_number)
       # Get future production orders data 
      start_date = Date.new(year, month_number, 1)
      end_date = Date.new(year, month_number, -1)
          
      pts_data = SapProductionTask.pts_data
      rts_data = SapProductionTask.rts_data
      used_pos = []
      @pos_with_date = {}

      #pts data 
      pts_data.each {|x|
        dt = [x.expected_rts_date, x.eta_coa_completion].compact.max
        dt = Date.current + 7.days if not dt #if there's no expected rts date or eta for coa assume it'll take 7 days from now to get onto RTS 
        while [0,6].include?(dt.wday) #if it lands on a weekend, add one day until its not a weekend 
          dt += 1.day
        end
        @pos_with_date[dt] ||= []
        @pos_with_date[dt] << [x.sap_product_order, "PTS"]
        used_pos << x.po_id
      }
      
      #add rts product orders 
      rts_data.each {|x|
        dt = Date.current #if it's in RTS ship it today
        if DateTime.current.hour >= 17 #unless it's after 5pm 
          dt += 1.day
        end
        while [0,6].include?(dt.wday) #or it's on a weekend 
          dt += 1.day
        end
        @pos_with_date[dt] ||= []
        @pos_with_date[dt] << [x.sap_product_order, "RTS"]
        used_pos << x.po_id
      }
  
      #add scheduled batches 
      bss = []
      BatchSchedule.where(bs_type: "packaging2").where("bs_date >= ? and bs_date <= ?", start_date - 7.days, end_date).each {|bs|
        next if used_pos.include?(bs.sap_po_id)
        next if not bs.sap_po_id
        next if BatchSchedule.where(bs_type: "packaging2").where(sap_po_id: bs.sap_po_id).order("bs_date desc").pluck(:bs_date).first > bs.bs_date
  
        dt = bs.bs_date + 7.days
        if bs.sap_product_order&.latest_end and dt < bs.sap_product_order&.latest_end
          dt = bs.sap_product_order&.latest_end.to_date
        end
  
        while [0,6].include?(dt.wday)
          dt += 1.day
        end
  
        @pos_with_date[dt] ||= []
        @pos_with_date[dt] << [bs.sap_product_order, "Scheduled", bs]
        used_pos << bs.sap_po_id
      }
  
      @pos_with_date.transform_values!{|v| v.reject{|x|x[1] == "Scheduled" and x[0].sap_production_tasks.any?{|x|x.status == 3}}}

      pos = []
      (1..@days_in_month).each do |date_day|
        date = Date.new(year, month_number, date_day)
        if @pos_with_date.select{|k,v|k == date} == [] || @pos_with_date.select{|k,v|k == date} == nil 
          pos << 0
        else 
          selected_values = @pos_with_date.select{|k,v|k == date}.flat_map{|k,v|v}.compact 
          total_revenue = selected_values.sum { |x| x[0] ? x[0].get_revenue2 : 0 }
          pos << total_revenue
        end  
      end  
      #  total_quantity = pos.sum{|x| x[0]&.planned_quantity.to_i or 0}    
      return pos 
      
    end 

    def replace_previous_with_actuals(year, month, actuals, planned)
      current_date = Date.current 
      (1..@days_in_month).each do |date_day|
        counter_date = Date.new(year, month, date_day)
        if counter_date < current_date 
          planned[date_day -1] = actuals[date_day -1]        
        end 
      end 
      return planned 
    end 

    def get_cumulative(daily_array)
      temp_value = 0 
      cumulative_array = []
      daily_array.each do |each|
          temp_value += each 
          cumulative_array << temp_value 
      end 
      return cumulative_array 
    end 

    def update_months
      puts "***** UPDATING MONTHS ********"
    end 

    #=======================================================================
    #region Helper Functions
    #=======================================================================

    def get_material_codes(po_id) 
      codes = {}
      codes["Boxes"] ||= []
      codes["Others"] ||= []
  
      if @data_by_po_id[po_id]
        @data_by_po_id[po_id].each do |material|
          item = material.material_code 
          if item != nil 
            skipFirst = item[3..-1]
            skipSix = item[6..-1]
            lastTwo = item[0..-3]
            lastThree = item[0..-4]
            case 
            when item.start_with?("BT-", "JA-"), item.start_with?("LS-BT-", "LS-JA-"), skipFirst && skipFirst.start_with?("-BT-", "-JA-")
              codes["Bottle"] = item
              codes["Glass"] = "X" if lastTwo.end_with?("-G-") || lastThree.end_with?("-G-")
            when item.start_with?("LI-"), item.start_with?("LS-LI-"), skipFirst && skipFirst.start_with?("-LI-")
              codes["Lid"] = item
            when item.start_with?("NB-"), item.start_with?("LS-NB-"), skipFirst && skipFirst.start_with?("-NB-")
              codes["Neck Band"] = item
            when item.start_with?("BX-"), item.start_with?("LS-BX-"), skipFirst && skipFirst.start_with?("-BX-")
              codes["Boxes"] << [item]
            when item.start_with?("LA-"), item.start_with?("LS-LA-"), skipFirst && skipFirst.start_with?("-LA-")
              codes["Label"] = item
            when item.start_with?("DE"), item.start_with?("LS-DE-"), skipFirst && skipFirst.start_with?("-DE-")
              codes["Dessicant"] = item
            when item.start_with?("SC-"), item.start_with?("LS-SC-"), skipFirst && skipFirst.start_with?("-SC-")
              codes["Scoop"] = item 
            when item.start_with?("DV"), item.start_with?("LS-DV-"), skipFirst && skipFirst.start_with?("-DV-")
              codes["Divider"] = item 
            when item.start_with?("CO-"), item.start_with?("LS-CO-"), skipFirst && skipFirst.start_with?("-CO-")
              codes["Cotton"] = item 
            when item.start_with?("CA-"), item.start_with?("LS-CA-"), skipFirst && skipFirst.start_with?("-CA-")
              codes["Capsule"] = item 
            when item.start_with?("CB-"), item.start_with?("LS-CB-"), skipFirst && skipFirst.start_with?("-CB-")
              codes["Consumer Box"] = item 
            when item.start_with?("BA-"), item.start_with?("LS-BA-"), skipFirst && skipFirst.start_with?("-BA-")
              codes["Bag"] = item 
            when item.start_with?("SA-"), item.start_with?("LS-SA-"), skipFirst && skipFirst.start_with?("-SA-")
              codes["Sachet"] = item 
            when item.start_with?("SP-"), item.start_with?("LS-SP-"), skipFirst && skipFirst.start_with?("-SP-")
              codes["Stick Pack"] = item 
            when item.start_with?("TR-"), item.start_with?("LS-TR-"), skipFirst && skipFirst.start_with?("-TR-")
              codes["Tray"] = item 
            when item.start_with?("ACC-", "ST-"), item.start_with?("LS-ACC-", "LS-ST-"), skipFirst && skipFirst.start_with?("-ACC-", "-ST-"), skipSix && skipSix.start_with?("-ACC-", "-ST-")
              codes["Sticker"] = item 
            when item == nil 
              puts "ITEM found NIL by get_material_codes helper function"
            else 
              codes["Others"] << [item]
            end 
          else 
            puts "**** MATERIAL CODE IS NIL ****"
          end 
        end
        return codes
      else 
        puts "***** DATA RETURNED NIL; NO REFERENCED DATA FROM PO_ID FOUND *****"
      end 
    end 
    helper_method :get_material_codes

    #=======================================================================
    #endregion 
    #endregion 
    #region Generate CSVs/Excel Functions
    #=======================================================================

    def generate_csv 
      run_quantities #run the code to initiate the data 
      if @dataFetchError == false 
        keys = @all_codes.to_h.keys 
        puts keys 
       
        respond_to do |format|
          
          format.csv {
            data = CSV.generate do |csv|
              #"Glass?", "Bottle", "Lid", "Neck Band", "Boxes", "Dessicant", "Cotton", "Label", "Scoop", "Divider", "Capsule", "Consumer Box", "Tray", "Sticker", "Bag", "Sachet", "Stick Pack", "Others"
              csv << ["PO_ID", "Product Name", "Product Desc", "Product Type", "Latest End", "Planned Quantity", "Fullfilled Quantity", "Status",
                      "Glass?", "Bottle", "Lid", "Neck Band", "Boxes", "Dessicant", "Cotton", "Label", "Scoop", "Divider", 
                      "Capsule", "Consumer Box", "Tray", "Sticker", "Bag", "Sachet", "Stick Pack", "Others"]
             
              @all_data.each do |row|
                csv_row = []
                codes = get_material_codes(row.po_id)
                keys_to_retrieve = ["Glass", "Bottle", "Lid", "Neck Band", "Boxes", "Dessicant", "Cotton", "Label", "Scoop", "Divider", "Capsule", "Consumer Box", "Tray", "Sticker", "Bag", "Sachet", "Stick Pack", "Others"]
                csv_row.concat(codes.values_at(*keys_to_retrieve))
                csv << [row.po_id, row.product_id, row.product_desc, row.product_type, row.latest_end, row.planned_quantity, row.fullfilled_quantity, row.status] + csv_row 
              end 
               
            end
            current_datetime = Time.now.strftime("%m-%d-%Y")
      
            csvFileName = current_datetime + "_productRunQuantitiesLast12Month.csv"
            send_data data, filename: csvFileName
          }
        end
      else 
        puts "***** Could not generate CSV *****"
      end 
    end 

    def generate_csv_shipping_targets
      date = params[:date]
      target = params[:target] 
      puts "**** TARGET: #{target}"
      shipping_targets(date.to_date, target.to_i) #run the code to initiate the data 
      if true 
        respond_to do |format|
          format.csv {
            data = CSV.generate do |csv|
              csv << ["Day Numbers"] + (1..@days_in_month).to_a
              csv << ["Day Names"] + @all_day_names    
              csv << ["Daily Target"] + @daily_targets
              csv << ["Cumulative Targets"] + @daily_cumulative_targets
              csv << ["Planned"] + @daily_planned
              csv << ["Cumulative Planned"] + @daily_cumulative_planned 
              csv << ["Actuals"] + @daily_actuals
              csv << ["Cumulative Actuals"] + @daily_cumulative_actuals 
            end
            current_datetime = Time.now.strftime("%m-%d-%Y")
      
            csvFileName = current_datetime + "_shipping_targets.csv"
            send_data data, filename: csvFileName
          }
        end
      else 
        puts "***** Could not generate CSV *****"
      end 
    end 
    #=======================================================================
    #endregion
    #=======================================================================
end 
