require 'rails_helper'

RSpec.describe Invoice, type: :model do
  it 'can persist total_hours up to 9999' do
    create(:invoice, total_hours: 9998.24)
    Invoice.last.total_hours.should eq 9998.24
  end

  it 'can persist rates up to $999' do
    create(:invoice, rate: Money.new(99843))
    Invoice.last.rate.format.should eq '$998.43'
  end
end
