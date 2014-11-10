describe LocationPlanPolicy do
  subject { LocationPlanPolicy }

  permissions :state_pending? do
    it "allows a manager to move to pending" do
      expect(subject).to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'manager_approved'))
    end

    it "does not allow an admin to jump down into pending from rm_approved" do
      expect(subject).not_to permit(User.new(role: 'admin'), LocationPlan.new(approval_state: 'rm_approved'))
    end
  end

  permissions :state_manager_approved? do
    it "allows a manager to approve a pending location_plan" do
      expect(subject).to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'pending'))
    end

    it "does not allow a manager to jump down from rm_approved" do
      expect(subject).not_to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'rm_approved'))
    end
  end

  permissions :state_rm_approved? do
    it "allows a rm to approve a location_plan" do
      expect(subject).to permit(User.new(role: 'rm'), LocationPlan.new(approval_state: 'manager_approved'))
    end

    it "does not allow a manager to move to rm_approved" do
      expect(subject).not_to permit(User.new(role: 'manager'), LocationPlan.new(approval_state: 'manager_approved'))
    end

    it "does not allow an admin to jump to rm_approved from pending" do
      expect(subject).not_to permit(User.new(role: 'admin'), LocationPlan.new(approval_state: 'pending'))
    end
  end
end
