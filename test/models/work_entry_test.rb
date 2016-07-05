require "test_helper"

class WorkEntryTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  context "#today" do
    test "includes all today's entries" do
      Timecop.freeze(Date.today - 10.minutes) do # Late last night
        create :work_entry, user: @user, date: Time.zone.now.to_date
      end

      Timecop.freeze(Date.today + 10.minutes) do # Early this AM
        @included = create :work_entry, user: @user, date: Time.zone.now.to_date
      end

      Timecop.freeze(Date.today + 1.day - 10.minutes) do # Late tonight
        assert_equals [@included], @user.work_entries.today
      end

      Timecop.freeze(Date.today + 1.day + 10.minutes) do # Early tomorrow AM
        assert_equals [], @user.work_entries.today
      end
    end
  end

  context "#this_week" do
    test "includes all this week's entries" do
      @monday = Time.zone.now.beginning_of_week

      Timecop.freeze(@monday - 10.minutes) do # Late last week
        create :work_entry, user: @user, date: Time.zone.now.to_date
      end

      Timecop.freeze(@monday + 10.minutes) do # Beginning of this week
        @included = create :work_entry, user: @user, date: Time.zone.now.to_date
        create :work_entry, date: Time.zone.now.to_date # another user (ignored)
      end

      Timecop.freeze(@monday + 1.week - 10.minutes) do # End of this week
        assert_equals [@included], @user.work_entries.this_week
      end

      Timecop.freeze(@monday + 1.week + 10.minutes) do # Early next week
        assert_equals [], @user.work_entries.this_week
      end
    end
  end
end
