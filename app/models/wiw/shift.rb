module Wiw
  class Shift < Wiw::Base
    include HTTParty
    base_uri 'https://api.wheniwork.com/2/shifts'
    headers 'W-Token' => Rails.application.secrets.wiw_token, 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json
    debug_output $stderr if Rails.env.development?

    attr_accessor :source_shift

    # NASTY helper method that destroys all shifts
    def self.delete_all!
      response = get '/', query: {include_allopen: true, include_pending: true, start: Time.zone.now.beginning_of_year.iso8601, end: Time.zone.now.end_of_year.iso8601}
      ids = response['shifts'].map{|s| s['id']}.join(',')
      puts "Deleting #{ids}"
      delete '', query: {ids: ids}
    end

    def self.find_all_for_location_plan(location_plan)
      s = location_plan.schedule.starts_on.in_time_zone.iso8601
      e = (location_plan.schedule.ends_on + 1).in_time_zone.iso8601

      response = get '/', query: {include_allopen: true, include_pending: true, start: s, end: e, location_id: location_plan.location.wiw_id, position_id: ActiveRecord::Base::Position.all.pluck(:wiw_id)}

      results = response['shifts'].map do |record|
        new(record)
      end

      return results
    end

    def self.find(id)
      response = get "/#{id}"
      new(response['shift'])
    end

    def self.build_from_shift(shift)
      s = new(
        location_id: shift.grade.location_plan.location.wiw_id,
        position_id: shift.position.wiw_id,
        start_time: shift.starts_at.rfc822,
        end_time: shift.ends_at.rfc822,
        published: true
      )

      s.id = shift.wiw_id if shift.wiw_id
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

    SYNC_FIELDS = ['location_id', 'position_id', 'start_time', 'end_time', 'published']

    # Given a regular Shift object, determine if this Wiw::Shift should be updated
    def should_update?(shift)
      other = Wiw::Shift.build_from_shift(shift)

      SYNC_FIELDS.any? do |field|
        other.attributes[field] != self.attributes[field]
      end
    end
  end
end
