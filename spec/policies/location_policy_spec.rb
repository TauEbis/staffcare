describe LocationPolicy do
  subject { LocationPolicy }

  #permissions :update? do
  #  it "denies access if location is published" do
  #    expect(subject).not_to permit(User.new(:admin => false), Location.new(:published => true))
  #  end
  #
  #  it "grants access if location is published and user is an admin" do
  #    expect(subject).to permit(User.new(:admin => true), Location.new(:published => true))
  #  end
  #
  #  it "grants access if location is unpublished" do
  #    expect(subject).to permit(User.new(:admin => false), Location.new(:published => false))
  #  end
  #end
end
