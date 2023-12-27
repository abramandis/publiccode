
class RedZoneManualRateChange < ApplicationRecord
    validates :sku, presence: true
    validates :rate, presence: true
    def self.add_changes(rate_changes)
        ActiveRecord::Base.transaction do
            rate_changes.each do |sku, rate|
                record = find_or_initialize_by(sku: sku)
                record.update(rate: rate)
            end
        end
    end
end
