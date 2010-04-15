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
        def create_new_user_from_ldap_with_family_id(creating_parent_or_child, family_id_match)
          group = find_parent_or_child_group(creating_parent_or_child)
          return nil if group.nil?
          
          group.auth_sources.all(:conditions => {:onthefly_register => true}).each do |ldap|
            ldap_user = ldap.find_user_by_family_id(family_id_match)

            if ldap_user
              user = create(*ldap_user) do |pending_user|
                pending_user.login = ldap_user.first[:login]
                pending_user.language = Setting.default_language
              end
              user.group_ids = ldap.group_ids

              if user.valid?
                logger.debug "redmine_ldap_user_family: Created matching user account #{user.login}" if logger && user
                break
              end
            end
          end
        end

        def try_to_login_with_auto_add_family(login, password)
          user = try_to_login_without_auto_add_family(login, password)

          if user && user.parent? && user.child.blank?
            User.create_new_user_from_ldap_with_family_id(:child, user.get_my_family_value)

          elsif user && user.child? && user.parent.blank?
            User.create_new_user_from_ldap_with_family_id(:parent, user.get_my_family_value)
          end
          
          user 
        end

        private

        def find_parent_or_child_group(parent_or_child)
          case parent_or_child
          when :parent
            parent_setting = Setting.plugin_redmine_ldap_user_family["parent_group_id"]
            Group.find_by_id(parent_setting)
          when :child
            child_setting = Setting.plugin_redmine_ldap_user_family["child_group_id"]
            Group.find_by_id(child_setting)
          else
            nil
          end
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
          find_family_record
        end

        def parent
          return nil unless child?
          find_family_record
        end

        def parent_or_child
          if parent?
            child
          elsif child?
            parent
          else
            nil
          end
        end

        def get_my_family_value
          if Setting.plugin_redmine_ldap_user_family["family_custom_field"]
            if custom_field = UserCustomField.find_by_id(Setting.plugin_redmine_ldap_user_family["family_custom_field"])
              custom_value_for(custom_field).value
            end
          end
        end

        def alternative_mail
          altmail = nil
          alternative_mail_field = Setting.plugin_redmine_ldap_user_family['parent_email_override_field']

          if alternative_mail_field.present?
            custom_value = custom_value_for(alternative_mail_field)
            altmail = custom_value.value if custom_value.value.present?
          end

          altmail
        end

        private

        def find_family_record
          family_value = CustomValue.find(:first,
                                          :conditions => ["value = :value AND customized_type = 'Principal' AND customized_id != :me",
                                                          {
                                                            :value => get_my_family_value,
                                                            :me => id
                                                          }])
          family_value.customized if family_value

        end
        
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
