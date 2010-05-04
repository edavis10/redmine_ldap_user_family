require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::UsersControllerTest < ActionController::TestCase

  context "IssuesController#show" do
    setup do
      @controller = UsersController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new

    end
    
    should "should reveal users with no visible activity or project" do
      @user = User.generate_with_protected!
      @request.session[:user_id] = nil
      get :show, :id => @user.id

      assert_response :success
      assert_template 'show'
    end
  end
  
end
