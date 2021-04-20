require 'resolv'

class DnsRecord < ApplicationRecord
    has_many :dns_hostnames, dependent: :destroy
    validates :ip, presence: true, :format => { :with => Resolv::IPv4::Regex }
end