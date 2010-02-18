# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

class ActiveSupport::TestCase
  def configure_plugin(fields={})
    Setting.plugin_redmine_ldap_user_family = fields.stringify_keys
  end

  def setup_plugin_configuration
    @custom_field = UserCustomField.generate!(:name => 'Student Id', :field_format => 'string')
    @auth_source = AuthSourceLdap.generate!(:name => 'localhost',
                                            :host => '127.0.0.1',
                                            :port => 389,
                                            :base_dn => 'OU=Person,DC=redmine,DC=org',
                                            :attr_login => 'uid',
                                            :attr_firstname => 'givenName',
                                            :attr_lastname => 'sn',
                                            :attr_mail => 'mail',
                                            :onthefly_register => true,
                                            :custom_attributes => {@custom_field.id.to_s => 'employeeNumber'})
    configure_plugin({
                       'family_custom_field' => @custom_field.id.to_s
                     })
  end
end

