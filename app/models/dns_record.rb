require 'resolv'

class DnsRecord < ApplicationRecord
    validates :ip, presence: true, :format => { :with => Resolv::IPv4::Regex }
end