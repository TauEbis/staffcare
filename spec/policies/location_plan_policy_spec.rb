describe LocationPlanPolicy do
  subject { LocationPlanPolicy }

  permissions :state_pending? do
    it "allows a manager to move to pending" do
      expect(subject).to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'manager_approved'))
    end

    it "does not allow an admin to jump down into pending from gm_approved" do
      expect(subject).not_to permit(User.new(role: 'admin'), LocationPlan.new(approval_state: 'gm_approved'))
    end
  end

  permissions :state_manager_approved? do
    it "allows a manager to approve a pending location_plan" do
      expect(subject).to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'pending'))
    end

    it "does not allow a manager to jump down from gm_approved" do
      expect(subject).not_to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'gm_approved'))
    end
  end

  permissions :state_gm_approved? do
    it "allows a gm to approve a location_plan" do
      expect(subject).to permit(User.new(role: 'gm'), LocationPlan.new(approval_state: 'manager_approved'))
    end

    it "does not allow a manager to move to gm_approved" do
      expect(subject).not_to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'manager_approved'))
    end

    it "does not allow an admin to jump to gm_approved from pending" do
      expect(subject).not_to permit(User.new(role: 'admin'), LocationPlan.new(approval_state: 'pending'))
    end
  end
end
