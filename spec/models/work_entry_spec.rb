require 'rails_helper'

describe WorkEntry do
  before do
    @user = create :user
  end

  describe "#today" do
    it "includes all today's entries" do
      Timecop.freeze(Date.today - 10.minutes) do # Late last night
        create :work_entry, user: @user, date: Date.today
      end

      Timecop.freeze(Date.today + 10.minutes) do # Early this AM
        @included = create :work_entry, user: @user, date: Date.today
      end

      Timecop.freeze(Date.today + 1.day - 10.minutes) do # Late tonight
        @user.work_entries.today.should == [@included]
      end

      Timecop.freeze(Date.today + 1.day + 10.minutes) do # Early tomorrow AM
        @user.work_entries.today.should == []
      end
    end
  end

  describe "#this_week" do
    it "includes all this week's entries" do
      @monday = Date.today.beginning_of_week

      Timecop.freeze(@monday - 10.minutes) do # Late last week
        create :work_entry, user: @user, date: Date.today
      end

      Timecop.freeze(@monday + 10.minutes) do # Beginning of this week
        @included = create :work_entry, user: @user, date: Date.today
        create :work_entry, date: Date.today # for another user (excluded)
      end

      Timecop.freeze(@monday + 1.week - 10.minutes) do # End of this week
        @user.work_entries.this_week.should == [@included]
      end

      Timecop.freeze(@monday + 1.week + 10.minutes) do # Early next week
        @user.work_entries.this_week.should == []
      end
    end
  end
end
