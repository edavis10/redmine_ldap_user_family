require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_ldap_user_family do
  require_dependency 'principal'
  require_dependency 'user'

  User.send(:include, RedmineLdapUserFamily::Patches::UserPatch)
end

Redmine::Plugin.register :redmine_ldap_user_family do
  name 'Redmine Ldap User Family plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  settings({
             :partial => 'settings/ldap_user_family',
             :default => {
               'family_custom_field' => nil
             }})
end
