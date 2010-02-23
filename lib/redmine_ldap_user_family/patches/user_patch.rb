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
          is_parent_or_child? == :parent
        end

        def child?
          is_parent_or_child? == :child
        end

        def child
          return nil unless parent?

          custom_field = UserCustomField.find_by_id(Setting.plugin_redmine_ldap_user_family["family_custom_field"])
          my_value = custom_value_for(custom_field).value

          family_name, last_two = *convert_to_child(my_value)

          child_value = CustomValue.find(:first,
                                         :conditions => ["value != :my_value AND value LIKE :family_name AND value like :last_two",
                                                         {
                                                           :my_value => my_value,
                                                           :family_name => family_name.to_s + '%',
                                                           :last_two => '%' + last_two.to_s
                                                         }])
          child_value.customized if child_value

        end

        def parent
          return nil unless child?

          custom_field = UserCustomField.find_by_id(Setting.plugin_redmine_ldap_user_family["family_custom_field"])
          my_value = custom_value_for(custom_field).value

          parent_value = CustomValue.find_by_value(convert_to_parent(my_value))
          parent_value.customized if parent_value

        end

        def convert_to_child(value)
          # Can't split on '-' because the first part might include a
          # hyphenated name
          [value[0, 7], value[8,2]]
        end

        def convert_to_parent(value)
          value[-3,1] = '-'
          value
        end
        
        private

        def is_parent_or_child?
          if Setting.plugin_redmine_ldap_user_family["family_custom_field"]
            if custom_field = UserCustomField.find_by_id(Setting.plugin_redmine_ldap_user_family["family_custom_field"])
              if value = custom_value_for(custom_field).value
                if value.match(User.parent_regexp)
                  return :parent
                elsif value.match(User.child_regexp)
                  return :child
                else
                  false
                end
              end
            end
          end
        end

      end    
    end
  end
end
