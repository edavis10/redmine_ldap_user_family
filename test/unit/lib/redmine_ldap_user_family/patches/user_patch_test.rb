require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::UserPatchTest < ActiveSupport::TestCase
  def generate_parent_user(attrs={})
    User.generate_with_protected!({:custom_field_values => {@custom_field.id.to_s => 'oneusec-23'}}.merge(attrs))
  end

  def generate_child_user(attrs={})
    User.generate_with_protected!({:custom_field_values => {@custom_field.id.to_s => 'oneusec123'}}.merge(attrs))
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

  context "#try_to_login" do
    setup do
      setup_plugin_configuration
      @test_password = {:password => 'testtesttest', :password_confirmation => 'testtesttest'}
    end
    
    context "user who isn't a parent or child" do
      should "do nothing" do
        @user = User.generate_with_protected!(@test_password)

        assert_no_difference('User.count') do
          assert_equal @user, User.try_to_login(@user.login, 'testtesttest')
        end
        
      end
    end

    context "user who is a child" do
      setup do
        @user = generate_child_user(@test_password)
      end

      should "check that the parent record exists" do
        User.any_instance.expects(:parent).returns(nil)
        assert @user, User.try_to_login(@user.login, 'testtesttest')
      end

      should "try to auto add the parent record from LDAP" do
        assert_difference('User.count') do
          assert_equal @user, User.try_to_login(@user.login, 'testtesttest')
        end

        assert @user.parent.present?
      end
    end

    context "user who is a parent" do
      setup do
        @user = generate_parent_user(@test_password)
      end

      should "check that the child record exists" do
        User.any_instance.expects(:child).returns(nil)
        assert @user, User.try_to_login(@user.login, 'testtesttest')
      end

      should "try to auto add the child record from LDAP" do
        assert_difference('User.count') do
          assert_equal @user, User.try_to_login(@user.login, 'testtesttest')
        end

        assert @user.child.present?
      end
    end
  end
end
