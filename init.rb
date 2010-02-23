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
