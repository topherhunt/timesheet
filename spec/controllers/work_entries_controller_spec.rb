require 'rails_helper'

describe WorkEntriesController do
  render_views

  before do
    @user = create :user
    sign_in @user
  end

  specify "#merge works properly" do
    p = create :project
    entry1 = create :work_entry, user: @user, project: p, date: '2015-05-19', duration: 2, invoice_notes: "abc"
    entry2 = create :work_entry, user: @user, project: p, date: '2015-05-20', duration: 1.5, invoice_notes: "def", admin_notes: "ghi"

    post :merge, from: entry2.id, to: entry1.id

    WorkEntry.count.should == 1
    entry1.reload
    entry1.duration.should == 3.5
    entry1.date.should     == Date.parse('2015-05-19')
    entry1.invoice_notes.should == "abc - def"
    entry1.admin_notes.should   == " - ghi"
  end
end
