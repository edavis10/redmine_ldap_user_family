module RedmineLdapUserFamily
  module Hooks
    class UserHooks < Redmine::Hook::ViewListener
      def view_account_left_bottom(context={})
        return '' unless context[:user]

        record = context[:user].parent_or_child

        if context[:user].parent?
          text = l(:ldap_user_family_text_parent_of, :record => record)
        elsif context[:user].child?
          text = l(:ldap_user_family_text_child_of, :record => record)
        else
          return ''
        end

        return content_tag(:h3, l(:ldap_user_family_text_family_relationship)) +
          content_tag(:p, link_to(text, :controller => 'users', :action => 'show', :id => record))
        
      end
    end
  end
end
