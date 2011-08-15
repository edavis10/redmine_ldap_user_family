module RedmineLdapUserFamily
  module Patches
    module IssuePatch

      def self.included(base)
        base.class_eval do
          # Automatically adds the family member to the recipients
          def recipients_with_user_family_included
            r = recipients_without_user_family_included
            mail = nil
            
            if author.child?
              mail = author.parent.try(:mail)
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
