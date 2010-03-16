# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

class ActiveSupport::TestCase
  def configure_plugin(fields={})
    Setting.plugin_redmine_ldap_user_family = fields.stringify_keys
  end

  def setup_plugin_configuration
    @parent_group = Group.generate!(:lastname => 'Parent')
    @child_group = Group.generate!(:lastname => 'Child')
    
    @custom_field = UserCustomField.generate!(:name => 'Student Id', :field_format => 'string')
    @custom_field_alternative_mail = UserCustomField.generate!(:name => 'Alternative Mail', :field_format => 'string')
    @parent_auth_source = AuthSourceLdap.generate!(:name => 'Parent',
                                                   :host => '127.0.0.1',
                                                   :port => 389,
                                                   :base_dn => 'OU=Person,DC=redmine,DC=org',
                                                   :attr_login => 'uid',
                                                   :attr_firstname => 'givenName',
                                                   :attr_lastname => 'sn',
                                                   :attr_mail => 'mail',
                                                   :onthefly_register => true,
                                                   :groups => [@parent_group],
                                                   :custom_attributes => {
                                                     @custom_field.id.to_s => 'employeeNumber',
                                                     @custom_field_alternative_mail.id.to_s => 'mail'
                                                   })

    @child_auth_source = AuthSourceLdap.generate!(:name => 'Child',
                                                  :host => '127.0.0.1',
                                                  :port => 389,
                                                  :base_dn => 'OU=Person,DC=redmine2,DC=org',
                                                  :attr_login => 'uid',
                                                  :attr_firstname => 'givenName',
                                                  :attr_lastname => 'sn',
                                                  :attr_mail => 'mail',
                                                  :onthefly_register => true,
                                                  :groups => [@child_group],
                                                  :custom_attributes => {
                                                    @custom_field.id.to_s => 'employeeNumber',
                                                    @custom_field_alternative_mail.id.to_s => 'mail'
                                                  })
    configure_plugin({
                       'family_custom_field' => @custom_field.id.to_s,
                       'parent_email_override_field' => @custom_field_alternative_mail.id.to_s,
                       'child_group_id' => @child_group.id.to_s,
                       'parent_group_id' => @parent_group.id.to_s
                     })
  end
end

