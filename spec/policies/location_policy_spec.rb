describe LocationPolicy do
  subject { LocationPolicy }

  #permissions :update? do
  #  it "denies access if location is locked" do
  #    expect(subject).not_to permit(User.new(:admin => false), Location.new(:locked => true))
  #  end
  #
  #  it "grants access if location is locked and user is an admin" do
  #    expect(subject).to permit(User.new(:admin => true), Location.new(:locked => true))
  #  end
  #
  #  it "grants access if location is unlocked" do
  #    expect(subject).to permit(User.new(:admin => false), Location.new(:locked => false))
  #  end
  #end
end
