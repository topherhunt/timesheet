require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  test "can persist total_hours up to 9999" do
    create(:invoice, total_hours: 9998.24)
    assert_equals 9998.24, Invoice.last.total_hours
  end

  test "can persist total bills up to $999" do
    create(:invoice, total_bill: Money.new(999843))
    assert_equals "$9,998.43", Invoice.last.total_bill.format
  end
end
