require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::UserPatchTest < ActiveSupport::TestCase
  context "#parent?" do
    setup do
      setup_plugin_configuration
    end
    
    should "return true on a parent record"
    should "return false on a child record" do
      @user = User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec123'})
      assert !@user.parent?
    end

    should "return false on a record missing the family_custom_field" do
      @user = User.generate_with_protected!
      assert !@user.parent?
    end
  end
end
