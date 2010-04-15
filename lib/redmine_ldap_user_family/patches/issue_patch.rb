module RedmineLdapUserFamily
  module Patches
    module IssuePatch

      def self.included(base)
        base.class_eval do
          # Automatically adds the family member to the recipients,
          # optionally using their alternative_mail address
          def recipients_with_user_family_included
            r = recipients_without_user_family_included
            mail = nil
            
            if author.parent? || author.child?
              mail = author.parent_or_child.alternative_mail
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
