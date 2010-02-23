module RedmineLdapUserFamily
  module Patches
    module UserPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          
        end

      end
      
      module ClassMethods

        # * 6 letters of the student's last name
        # * 1 letter of the student's first name
        # * student number:
        #  * for students: 3 numbers
        #  * for parents: 1 hyphen and the last two numbers of the related student id
        def parent_regexp
          /\A[\w ]{6}\w{1}-[\w]{2}\z/i
        end

        def child_regexp
          /\A[\w ]{6}\w{1}[\w]{3}\z/i
        end

        def parent_or_child_regexp
          /\A[\w ]{6}\w{1}[\w|-][\w]{2}\z/i
        end
      end
      
      module InstanceMethods
        def parent?
          
          
          if Setting.plugin_redmine_ldap_user_family["family_custom_field"]
            custom_field = UserCustomField.find_by_id(Setting.plugin_redmine_ldap_user_family["family_custom_field"])

            if custom_field
              value = custom_value_for(custom_field).value

              if value && value.match(User.parent_regexp)
                return true
              end
            end
          end
        end

        def child?
          !parent?
        end
      end    
    end
  end
end
