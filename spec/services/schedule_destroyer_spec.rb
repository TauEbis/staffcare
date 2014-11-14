require 'spec_helper'

describe ScheduleDestroyer, :type => :service do

  describe "Given a schedule and its dependency tree" do

    let!(:schedule)         { create(:schedule_with_children) }
    let!(:destroyer)         { ScheduleDestroyer.new(schedule.reload) } # to reload associations

    context "when #destroy is called" do

      it "deletes all visit_projection children" do
        vp_count = schedule.visit_projections.count
        expect{ destroyer.destroy }.to change(VisitProjection, :count).by(-1*vp_count)
      end

      it "deletes all location_plan children" do
        lp_count = schedule.location_plans.size
        expect{ destroyer.destroy }.to change(LocationPlan, :count).by(-1*lp_count)
      end

      it "deletes all grade grandchildren" do
        g_count = schedule.location_plans.flat_map(&:grade_ids).uniq.count
        expect{ destroyer.destroy }.to change(Grade, :count).by(-1*g_count)
      end

      it "deletes all shift great-grandchildren" do
        s_count = schedule.location_plans.flat_map(&:grades).flat_map(&:shift_ids).uniq.count
        expect{ destroyer.destroy }.to change(Shift, :count).by(-1*s_count)
      end

      it "deletes all push grandchildren" do
        p_count = schedule.location_plans.flat_map(&:push_ids).uniq.count
        expect{ destroyer.destroy }.to change(Push, :count).by(-1*p_count)
      end

      it "deletes the schedule" do
        expect{ destroyer.destroy }.to change(Schedule, :count).by(-1)
      end

      it "should return true if the transaction executes succesfully" do
        expect( destroyer.destroy ).to be(true)
      end

      it "should return false if the transaction doesn't executes succesfully" do
        ActiveRecord::Base.stub(:transaction).and_return([])
        expect( destroyer.destroy ).to be(false)
      end

    end
  end
end
