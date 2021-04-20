class DnsHostname < ApplicationRecord
    belongs_to :dns_record
    validates :dns_record_id, presence: true
    validates :hostname, presence: true
end