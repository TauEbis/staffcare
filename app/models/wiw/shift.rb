module Wiw
  class Shift
    include HTTParty
    base_uri 'https://api.wheniwork.com/2/shifts'
    headers 'W-Token' => Rails.application.secrets.wiw_token, 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    attr_accessor :attributes

    def self.find_for_day(day)

    end

    def self.build_from_shift(shift)
      s = new(
        location_id: shift.grade.location_plan.location.wiw_id,
        position_id: Rails.application.secrets.wiw_position_id,
        start_time: shift.starts_at.iso8601,
        end_time: shift.ends_at.iso8601
      )

      s.attributes[:id] = shift.wiw_id if shift.wiw_id

      s
    end

    def initialize(attributes = {})
      @attributes = attributes
    end

    def id
      @attributes[:id]
    end

    def to_hash
      @attributes.dup
    end

    def to_json
      to_hash.to_json
    end

    def create
      self.class.post '', body: to_json
    end

    def update
      if id.blank?
        raise "Can't update Wiw::Shift without an id"
      end

      self.class.put "/#{id}", body: to_json
    end

    def delete
      if id.blank?
        raise "Can't delete Wiw::Shift without an id"
      end

      self.class.delete "/#{id}"
    end

  end
end
