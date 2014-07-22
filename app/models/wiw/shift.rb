module Wiw
  class Shift < Wiw::Base
    include HTTParty
    base_uri 'https://api.wheniwork.com/2/shifts'
    headers 'W-Token' => Rails.application.secrets.wiw_token, 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    attr_accessor :source_shift

    def self.position_id
      Rails.application.secrets.wiw_position_id
    end

    def self.find_all_for_location_plan(location_plan)
      s = location_plan.schedule.starts_on.in_time_zone.iso8601
      e = (location_plan.schedule.ends_on + 1).in_time_zone.iso8601

      response = get '/', query: {start: s, end: e, location_id: location_plan.location.wiw_id, position_id: position_id}

      results = response['shifts'].map do |record|
        new(record)
      end

      return results
    end

    def self.find_for_day(day)

    end

    def self.build_from_shift(shift)
      s = new(
        location_id: shift.grade.location_plan.location.wiw_id,
        position_id: position_id,
        start_time: shift.starts_at.iso8601,
        end_time: shift.ends_at.iso8601
      )

      # We store ids as strings to be safe, but they come from WIW as integers
      # So we convert here so Wiw::Shift records can be ==
      s.id = shift.wiw_id.to_i if shift.wiw_id
      s.source_shift = shift

      s
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
