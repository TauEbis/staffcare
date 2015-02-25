require 'spec_helper'

describe LocationPlansHelper do
  subject { Class.new.extend described_class }

  describe '#open_close_times_for grade' do
    let(:grade) { create :grade_with_children }
    let(:days)  { Location::DAYS }
    let(:ante_meridiem) { 12 }

    it 'humanizes day' do
      days.each do |day|
        expect( subject.open_close_times_for(grade) )
          .to match %r(<time>#{day.humanize})
      end
    end

    it 'displays open times' do
      days.each_with_index do |day, i|
        expect( subject.open_close_times_for(grade) )
          .to match %r(#{grade.open_times[i]}am)
      end
    end

    it 'displays close times' do
      days.each_with_index do |day, i|
        expect( subject.open_close_times_for(grade) )
          .to match %r(#{grade.close_times[i] - ante_meridiem}pm)
      end
    end
  end
end
