require 'spec_helper'

describe Users::RegistrationsController do
  # let(:user) { FactoryGirl.create(:user) }

  # before do
  #   login_user user
  # end

  it "Registration #create" do

    expect{ post :create, "user"=>{"website"=>"http://www.myself.com", "email"=>"example@example.com"}}.to change(User, :count).by(1)
    response.body.should_not be_nil
  end
end
