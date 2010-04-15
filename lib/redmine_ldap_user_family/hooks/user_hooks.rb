module RedmineLdapUserFamily
  module Hooks
    class UserHooks < Redmine::Hook::ViewListener
      def view_account_left_bottom(context={})
        return '' unless context[:user]

        return display_if_alternative_mail_is_used(context[:user]) +
          display_family_relationship(context[:user])
      end

      private

      def display_if_alternative_mail_is_used(user)
        if alt_mail = user.alternative_mail
          content_tag(:h3, l(:ldap_user_family_text_alternative_mail)) +
            content_tag(:p, l(:ldap_user_family_text_using_alternative_mail, :mail => mail_to(alt_mail, nil, :encode => "javascript")))

        else
          ''
        end
      end

      def display_family_relationship(user)
        record = user.parent_or_child

        if user.parent?
          text = l(:ldap_user_family_text_parent_of, :record => record)
        elsif user.child?
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
