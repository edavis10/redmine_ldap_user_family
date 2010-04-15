require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_ldap_user_family do
  require_dependency 'principal'
  require_dependency 'user'

  unless User.included_modules.include? RedmineLdapUserFamily::Patches::UserPatch
    User.send(:include, RedmineLdapUserFamily::Patches::UserPatch)
  end

  require_dependency 'auth_source'
  require_dependency 'auth_source_ldap'

  AuthSourceLdap.send(:include, RedmineLdapUserFamily::Patches::AuthSourceLdapPatch)

  require_dependency 'issue'
  Issue.send(:include, RedmineLdapUserFamily::Patches::IssuePatch)
end

require 'redmine_ldap_user_family/hooks/user_hooks'

Redmine::Plugin.register :redmine_ldap_user_family do
  name 'LDAP User Family'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author_url 'http://www.littlestreamsoftware.com'

  description 'LDAP user family is a plugin to associate two records in Redmine using LDAP attributes.'

  version '0.1.0'
  
  settings({
             :partial => 'settings/ldap_user_family',
             :default => {
               'family_custom_field' => nil,
               'parent_email_override_field' => nil,
               'child_group_id' => nil,
               'parent_group_id' => nil
             }})
end
