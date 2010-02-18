require 'redmine'

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
