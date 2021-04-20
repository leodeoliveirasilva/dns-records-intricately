module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        all_dns = DnsRecord.all
        render json: {status: 'SUCCESS', message:'Loaded articles', data: all_dns}, status: :ok
      end

      # POST /dns_records
      def create
        dns_record = DnsRecord.new(dns_params)
        
        unless dns_record.valid?
          return render json: { errors: dns_record.errors }, status: :bad_request 
        end

        if dns_record.save
          render json: { id: dns_record.id }, status: :created
        else
          render json: { errors: dns_record.errors }, status: :internal_server_error
        end
      rescue ActiveRecord::RecordNotUnique => e
        render status: :conflict
      end

      private

      def dns_params
        params.permit(:ip)
      end
    end
  end
end
