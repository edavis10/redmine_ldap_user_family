require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::UserPatchTest < ActiveSupport::TestCase
  def generate_parent_user
    User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec-23'})
  end

  def generate_child_user
    User.generate_with_protected!(:custom_field_values => {@custom_field.id.to_s => 'oneusec123'})
  end

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

  context "#child" do
    setup do
      setup_plugin_configuration
    end

    context "on a child record" do
      should "return nil" do
        @child = generate_child_user

        assert_equal nil, @child.child
      end
    end

    context "on a parent record" do
      should "return the child record from Redmine" do
        @parent = generate_parent_user
        @child = generate_child_user

        assert_equal @child, @parent.child
      end
      
      should "return nil if no child record is found" do
        @parent = generate_parent_user

        assert_equal nil, @parent.child
      end
    end
  end
  
  context "#parent" do
    setup do
      setup_plugin_configuration
    end

    context "on a parent record" do
      should "return nil" do
        @parent = generate_parent_user

        assert_equal nil, @parent.parent
      end
    end

    context "on a child record" do
      should "return the parent record from Redmine" do
        @parent = generate_parent_user
        @child = generate_child_user

        assert_equal @parent, @child.parent
      end
      
      should "return nil if no parent record is found" do
        @child = generate_child_user

        assert_equal nil, @child.parent
      end
    end
  end
end
