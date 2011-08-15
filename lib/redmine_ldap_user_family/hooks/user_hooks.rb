module RedmineLdapUserFamily
  module Hooks
    class UserHooks < Redmine::Hook::ViewListener
      def view_account_left_bottom(context={})
        return '' unless context[:user]

        return display_family_relationship(context[:user])
      end

      private

      def display_family_relationship(user)
        content = ''
        if user.parent?
          user.children.compact.each do |child|
            text = l(:ldap_user_family_text_parent_of, :record => child)
            content += link_to_family(text, child)
          end
        elsif user.child?
          record = user.parent
          text = l(:ldap_user_family_text_child_of, :record => record)
          content += link_to_family(text, record)
        else
          return ''
        end

        return content_tag(:h3, l(:ldap_user_family_text_family_relationship)) + content
          

      end

      def link_to_family(text, family_member)
        content_tag(:p, link_to(text, :controller => 'users', :action => 'show', :id => family_member))
      end

    end
  end
end
