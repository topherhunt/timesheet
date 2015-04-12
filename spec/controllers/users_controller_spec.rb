require 'rails_helper'

describe UsersController do
  describe "get #show" do
    it "assigns the @user object" do
      user = create :user
      get :show, id: user.id

      assigns(:user).should eq user
    end
  end
end
