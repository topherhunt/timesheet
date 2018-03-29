require "test_helper"

class WorkEntryTest < ActiveSupport::TestCase
  setup do
    @user = create :user
  end

  describe "#today" do
    test "includes all today's entries" do
      @start = Time.current.beginning_of_day
      entry1 = create :work_entry, user: @user, started_at: @start - 10.minutes
      entry2 = create :work_entry, user: @user, started_at: @start + 10.minutes
      entry3 = create :work_entry, user: @user, started_at: @start + (23.9).hours
      entry4 = create :work_entry, user: @user, started_at: @start + (24.1).hours

      Timecop.freeze(@start - 10.minutes) do # Late last night
        assert_equals [entry1], @user.work_entries.today
      end

      Timecop.freeze(@start + 10.minutes) do # Early this AM
        assert_equals [entry2, entry3], @user.work_entries.today
      end

      Timecop.freeze(@start + 1.day - 10.minutes) do # Late tonight
        assert_equals [entry2, entry3], @user.work_entries.today
      end

      Timecop.freeze(@start + 1.day + 10.minutes) do # Early tomorrow AM
        assert_equals [entry4], @user.work_entries.today
      end
    end
  end

  describe "#this_week" do
    test "includes all this week's entries" do
      @monday = Time.current.beginning_of_week
      entry1 = create :work_entry, user: @user, started_at: @monday - 1.hour
      entry2 = create :work_entry, user: @user, started_at: @monday + 1.hour
      entry3 = create :work_entry, user: @user, started_at: @monday + (6.9).days
      entry4 = create :work_entry, user: @user, started_at: @monday + (7.1).days

      Timecop.freeze(@monday - 10.minutes) do # Late last week
        assert_equals [entry1], @user.work_entries.this_week
      end

      Timecop.freeze(@monday + 10.minutes) do # Beginning of this week
        assert_equals [entry2, entry3], @user.work_entries.this_week
      end

      Timecop.freeze(@monday + 1.week - 10.minutes) do # End of this week
        assert_equals [entry2, entry3], @user.work_entries.this_week
      end

      Timecop.freeze(@monday + 1.week + 10.minutes) do # Early next week
        assert_equals [entry4], @user.work_entries.this_week
      end
    end
  end
end
