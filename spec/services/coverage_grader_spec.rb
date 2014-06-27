require 'spec_helper'

describe CoverageGrader, :type => :service do
	let (:grader) { CoverageGrader.new(md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4) }
	let (:coverage) { Array(4,2) + Array(20,3) + Array(4, 2) }
	let (:visits ) { [3.08, 4.54, 4.97, 3.17, 3.85, 2.74, 3.60, 3.85, 3.08, 3.34, 3.51, 3.60, 3.17, 3.60, 3.68, 2.57, 3.00, 3.08, 4.63, 3.51, 4.37, 4.28, 3.25, 2.48, 2.48, 2.14, 1.45, 0.77] }
	let (:penalty) { grader.penalty_with_set_visits(coverage, visits) }

	subject { grader }

		it { should respond_to(:penalty) }
		it { should respond_to(:set_visits=) }
		it { should respond_to(:penalty_with_set_visits) }

		describe "#set_visits" do
			before { grader.set_visits=visits }
			context "when penalty is called it should equal the penalty" do
				let (:penalty_2)  { grader.penalty(coverage) }
				expect(penalty_2).to eq(penalty)
			end
		end
end


=begin

describe Micropost do
	let (:user) { FactoryGirl.create(:user) }
	#let (:micropost) { user.microposts.build(content: "Lorem Ipsum") }
  let (:micropost) { FactoryGirl.build(:micropost, user: user) }

  subject { micropost }

  	it { should respond_to(:content) }
  	it { should respond_to(:user_id) }
  	it { should respond_to(:user) }
  	its(:user) { should eq user }

  	it { should be_valid }

  	context "when user_id is not present" do
  		before { micropost.user_id = nil }
  		it {should_not be_valid}
  	end

    context "when content is not present" do
      before { micropost.content = nil }
      it {should_not be_valid}
    end

    context "when content is blank" do
      before { micropost.content = " " }
      it {should_not be_valid}
    end

    context "when content is too long (limit 140)" do
      before { micropost.content = 'a'*141 }
      it {should_not be_valid}
    end

=end
