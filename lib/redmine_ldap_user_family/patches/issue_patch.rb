module RedmineLdapUserFamily
  module Patches
    module IssuePatch

      def self.included(base)
        base.class_eval do
          def recipients_with_user_family_included
            r = recipients_without_user_family_included
            mail = nil
            
            if author.parent? || author.child?
              alternative_mail = Setting.plugin_redmine_ldap_user_family['parent_email_override_field']

              if alternative_mail.present?
                custom_value = author.parent_or_child.custom_value_for(alternative_mail)
                mail = custom_value.value if custom_value.value.present?
              end

              mail ||= author.parent_or_child.mail
            end

            r << mail if mail.present?
            r.compact.uniq
          end

          alias_method_chain :recipients, :user_family_included

        end
      end
    end
  end
end