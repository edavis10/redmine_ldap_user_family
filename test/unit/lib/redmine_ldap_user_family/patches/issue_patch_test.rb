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

    end

    context "with an issue created a normal user" do
      should "not include the parents's mail"
      should "not include the child's mail"
    end

  end
end
