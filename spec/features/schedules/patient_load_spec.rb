require 'spec_helper'

feature 'Patient Load:', :js do

  subject { page }

  given(:admin)     { FactoryGirl.create :admin_user }
  given!(:schedule) { FactoryGirl.create :schedule_with_children }
  given(:grade)     { schedule.grades.first }

  before { schedule.reload }

  background do
    signin admin
    visit schedules_path


    click_link 'Schedules'

    sleep 1
    first('.panel .panel-heading a').click

    sleep 1
    click_link 'Manhattan' # first('div.row a').click

    sleep 1
    first('div.table h4 a').click

    sleep 1
    click_button 'Copy'

    sleep 1
    click_link "I'll use the defaults. Let's get started!"

    sleep 2
    scroll_to :coverage_view
  end

  scenario 'displays patients per hour' do
    within find('#positions').first('.shifts') do
      all('h5').each do |e|
        expect( e.text ).to match(/pph/)
      end
    end

    it { should have_title full_title('All Schedules') }
    it { should have_content("State") }
  end

  context 'when removing shift' do
    before do
    end

    scenario { }
  end

  context 'when adding shift' do
    before do
    end

    scenario { }
  end

  context 'when altering duration of shift' do
    before do
    end

    scenario { }
  end
end
