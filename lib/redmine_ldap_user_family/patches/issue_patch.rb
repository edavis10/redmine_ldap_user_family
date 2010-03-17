module RedmineLdapUserFamily
  module Patches
    module IssuePatch

      def self.included(base)
        base.class_eval do
          def recipients_with_user_family_included
            r = recipients_without_user_family_included

            if author.parent? && author.child.present?
              alternative_mail = Setting.plugin_redmine_ldap_user_family['parent_email_override_field']
              
              if alternative_mail.present?

                custom_value = author.child.custom_value_for(alternative_mail)
                if custom_value.value.present?
                  r << custom_value.value
                end
              else
                r << author.child.mail
              end
            end

            if author.child? && author.parent.present?
              alternative_mail = Setting.plugin_redmine_ldap_user_family['parent_email_override_field']
              
              if alternative_mail.present?

                custom_value = author.parent.custom_value_for(alternative_mail)
                if custom_value.value.present?
                  r << custom_value.value
                end
              else
                r << author.parent.mail
              end
            end

            r.compact.uniq
          end

          alias_method_chain :recipients, :user_family_included

        end
      end
    end
  end
end
