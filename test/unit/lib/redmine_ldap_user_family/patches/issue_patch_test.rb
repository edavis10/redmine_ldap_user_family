require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineLdapUserFamily::Patches::IssuePatchTest < ActiveSupport::TestCase
  context "Issue#recipients" do
    setup do
      setup_plugin_configuration
      @project = Project.generate!
      @parent = generate_parent_user(:login => 'parent')
      @child = generate_child_user(:login => 'child')
    end

    context "with an issue created by a parent" do
      setup do
        @issue = Issue.generate!(:author => @parent,
                                 :project => @project,
                                 :tracker => @project.trackers.first)
      end
      
      should "include the child's mail" do
        assert @issue.recipients.include?(@child.mail)
      end

      context "with a child with an alternative mail" do
        setup do
          @previous_mail = @child.mail
          @child.custom_field_values = {@custom_field_alternative_mail.id.to_s => 'alt@example.com'}
          assert @child.save
          assert_equal 'alt@example.com', @child.custom_value_for(@custom_field_alternative_mail).value
        end

        should "include the child's alternative mail" do
          assert @issue.recipients.include?('alt@example.com')
        end
        
        should "not include the child's mail" do
          assert !@issue.recipients.include?(@previous_mail)
        end
      end
    end
    
    context "with an issue created by a child" do
      setup do
        @issue = Issue.generate!(:author => @child,
                                 :project => @project,
                                 :tracker => @project.trackers.first)
      end
      
      should "include the parents's mail" do
        assert @issue.recipients.include?(@parent.mail)
      end

      context "with a parent with an alternative mail" do
        setup do
          @previous_mail = @parent.mail
          @parent.custom_field_values = {@custom_field_alternative_mail.id.to_s => 'alt@example.com'}
          assert @parent.save
          assert_equal 'alt@example.com', @parent.custom_value_for(@custom_field_alternative_mail).value
        end
        
        should "include the parents's alternative mail" do
          assert @issue.recipients.include?('alt@example.com')
        end
        
        should "not include the parents's mail" do
          assert !@issue.recipients.include?(@previous_mail)
        end
      end
    end

    context "with an issue created a normal user" do
      should "not include the parents's mail"
      should "not include the child's mail"
    end

  end
end
