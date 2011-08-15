require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::UserPatchTest < ActiveSupport::TestCase
  context "#parent?" do
    setup do
      setup_plugin_configuration
    end
    
    should "return true on a parent record" do
      assert generate_parent_user.parent?
    end
    
    should "return false on a child record" do
      assert !generate_child_user.parent?
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
      assert !generate_parent_user.child?
    end
    
    should "return true on a child record" do
      assert generate_child_user.child?
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
      should "return the first child record from Redmine" do
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
  
  context "#children" do
    setup do
      setup_plugin_configuration
    end

    context "on a child record" do
      should "return an empty array" do
        @child = generate_child_user

        assert_equal [], @child.children
      end
    end

    context "on a parent record" do
      should "return all of the children from Redmine" do
        @parent = generate_parent_user
        @child = generate_child_user
        @child2 = generate_child_user

        assert_equal [@child, @child2].sort, @parent.children.sort
      end
      
      should "return an empty array if no child record is found" do
        @parent = generate_parent_user

        assert_equal [], @parent.children
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
        assert @user.parent.parent?
        assert @user.parent.groups.include?(@parent_group)
      end
    end

    context "user who is a parent" do
      setup do
        @user = generate_parent_user(@test_password)
      end

      should "not try to auto add the child record from LDAP" do
        assert_no_difference('User.count') do
          assert_equal @user, User.try_to_login(@user.login, 'testtesttest')
        end
      end
    end
  end
end
