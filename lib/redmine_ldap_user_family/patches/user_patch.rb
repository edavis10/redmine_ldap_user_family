module RedmineLdapUserFamily
  module Patches
    module UserPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          class << self
            alias_method_chain :try_to_login, :auto_add_family
          end
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

        def create_new_user_from_ldap_with_family_id(family_id_match)
          AuthSourceLdap.all(:conditions => {:onthefly_register => true}).each do |ldap|
            ldap_user = ldap.find_user_by_family_id(family_id_match)

            if ldap_user
              user = create(*ldap_user) do |pending_user|
                pending_user.login = ldap_user.first[:login]
                pending_user.language = Setting.default_language
                pending_user.group_ids << ldap.group_ids
              end
              if user.valid?
                logger.debug "redmine_ldap_user_family: Created matching user account #{user.login}" if logger && user
                break
              end
            end
          end
        end

        def try_to_login_with_auto_add_family(login, password)
          user = try_to_login_without_auto_add_family(login, password)
          if user && user.parent?
            if user.child.blank?
              family_id, last_two = *user.convert_to_child(user.get_my_family_value)

              User.create_new_user_from_ldap_with_family_id(family_id)
            end
          elsif user && user.child?
            if user.parent.blank?
              family_id = user.convert_to_parent(user.get_my_family_value)

              User.create_new_user_from_ldap_with_family_id(family_id)
            end
          end
          
          user 
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

          child_value = CustomValue.find(:first,
                                         :conditions => ["value = :value AND customized_type = 'Principal' AND customized_id != :me",
                                                         {
                                                           :value => convert_to_child(get_my_family_value),
                                                           :me => id
                                                         }])
          child_value.customized if child_value
        end

        def parent
          return nil unless child?

          parent_value = CustomValue.find(:first,
                                         :conditions => ["value = :value AND customized_type = 'Principal' AND customized_id != :me",
                                                         {
                                                           :value => convert_to_parent(get_my_family_value),
                                                           :me => id
                                                         }])
          parent_value.customized if parent_value
        end

        def get_my_family_value
          if Setting.plugin_redmine_ldap_user_family["family_custom_field"]
            if custom_field = UserCustomField.find_by_id(Setting.plugin_redmine_ldap_user_family["family_custom_field"])
              custom_value_for(custom_field).value
            end
          end
        end

        def convert_to_child(value)
          value
        end

        def convert_to_parent(value)
          value
        end
        
        private

        def is_parent_or_child?
          case
          when Setting.plugin_redmine_ldap_user_family["parent_group_id"] &&
              group_ids.include?(Setting.plugin_redmine_ldap_user_family["parent_group_id"].to_i)
            return :parent
          when Setting.plugin_redmine_ldap_user_family["child_group_id"] &&
              group_ids.include?(Setting.plugin_redmine_ldap_user_family["child_group_id"].to_i)
            return :child
          else
            false
          end
        end
        
      end
    end
  end    
end
