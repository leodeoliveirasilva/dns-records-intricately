require 'will_paginate/array'

module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        per_page = 10
        unless params[:page].present?
          return render json: { error: 'page params is required' }, status: :bad_request 
        end
        
        allow_list = params[:included].present? ? params[:included].split(',') : []
        deny_list = params[:excluded].present? ? params[:excluded].split(',') : []
        dns_list_response = []

        if allow_list.empty?
          dns_list_response = DnsRecord.all
        else
          dns_list_response = allowed_dns(allow_list)
        end

        unless deny_list.empty?
          dns_list_response = dns_list_response.reject {|record| 
            record.dns_hostnames.pluck(:hostname).each_cons(deny_list.size).include?(deny_list) 
          }
        end

        related_hostnames = {}
        dns_list_response.each do |record|
          record.dns_hostnames.each do |host|
            unless allow_list.include?(host.hostname)
              related_hostnames[host.hostname] = 
              (related_hostnames[host.hostname] == nil ? 0 : related_hostnames[host.hostname]) + 1
            end
          end
        end

        render json: {
          total_records: dns_list_response.size,
          records: dns_list_response
            .paginate(page: params[:page], per_page: per_page)
            .map {|obj| {id: obj[:id], ip_address: obj[:ip]}},
          related_hostnames: related_hostnames.map{ |k,v| {hostname: k, count: v}}  
        }, status: :ok
      end

      # POST /dns_records
      def create
        dns_record = DnsRecord.new(dns_params)
        
        unless dns_record.valid?
          return render json: { errors: dns_record.errors }, status: :bad_request 
        end
        dns_record.transaction do
          unless dns_record.save
            return render json: { errors: "Error saving dns record" }, status: :internal_server_error
          end
          
          DnsHostname.insert_all(dns_hostnames_params(dns_record.id))
        end

        render json: { id: dns_record.id }, status: :created
      rescue ActiveRecord::RecordNotUnique => e
        render status: :conflict
      end

      private

      def dns_params
        params[:dns_records].permit(:ip)
      end

      def dns_hostnames_params(dns_record_id)
        params[:dns_records][:hostnames_attributes].map{ |h| { 
          dns_record_id: dns_record_id, 
          hostname: h[:hostname],
          created_at: Time.now,
          updated_at: Time.now
        }}
      end

      def allowed_dns(allow_list)
        return DnsRecord
          .select(:id, :ip)
          .joins(:dns_hostnames)
          .where('dns_hostnames.hostname IN (?)', allow_list)
          .group(:id, :ip).having("count(dns_records.id) = ?", allow_list.size).order(:id)
      end

    end
  end
end
