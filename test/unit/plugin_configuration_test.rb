require File.dirname(__FILE__) + '/../test_helper'

class PluginConfigurationTest < ActiveSupport::TestCase
  context "family custom field configuration option" do
    should 'exist' do
      assert Setting.plugin_redmine_ldap_user_family.keys.include?('family_custom_field'), "No key found in: #{Setting.plugin_redmine_ldap_user_family.keys}"
    end

    should "default to nil" do
      Setting.find_by_name('plugin_redmine_ldap_user_family').try(:destroy)
      assert_equal nil, Setting['plugin_redmine_ldap_user_family']['family_custom_field'] # Bypass cache
    end

  end

end
