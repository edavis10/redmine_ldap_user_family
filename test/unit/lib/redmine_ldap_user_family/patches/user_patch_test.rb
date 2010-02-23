require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::UserPatchTest < ActiveSupport::TestCase
  context "#parent?" do
    setup do
      setup_plugin_configuration
    end
    
    should "return true on a parent record" do
      @user = User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec-23'})
      assert @user.parent?
    end
    
    should "return false on a child record" do
      @user = User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec123'})
      assert !@user.parent?
    end

    should "return false on a record missing the family_custom_field" do
      @user = User.generate_with_protected!
      assert !@user.parent?
    end
  end

  context "#child?" do
    setup do
      setup_plugin_configuration
    end
    
    should "return false on a parent record" do
      @user = User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec-23'})
      assert !@user.child?
    end
    
    should "return true on a child record" do
      @user = User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec123'})
      assert @user.child?
    end

    should "return false on a record missing the family_custom_field" do
      @user = User.generate_with_protected!
      assert !@user.child?
    end
  end
end
