module RedmineLdapUserFamily
  module Patches
    module IssuePatch

      def self.included(base)
        base.class_eval do
          def recipients_with_user_family_included
            r = recipients_without_user_family_included
            
            r << author.child.mail if author.parent? && author.child.present?
            r << author.parent.mail if author.child? && author.parent.present?
            
            r.compact.uniq
          end

          alias_method_chain :recipients, :user_family_included

        end
      end
    end
  end
end
