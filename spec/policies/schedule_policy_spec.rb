describe SchedulePolicy do
  subject { SchedulePolicy }

  permissions :create? do
    it "allows an admin to create a schedule" do
      expect(subject).to permit(User.new(role: 'admin'), Schedule.new)
    end

    it "does not allow a scheduler to create a schedule" do
      expect(subject).not_to permit(User.new(role: 'scheduler'), Schedule.new)
    end
  end

end
