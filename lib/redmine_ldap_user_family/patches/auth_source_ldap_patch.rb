module RedmineLdapUserFamily
  module Patches
    module AuthSourceLdapPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
      end

      module ClassMethods
      end

      module InstanceMethods
        # TODO: Rip and replace of AuthSourceLdap#authenticate
        def find_user_by_family_id(family_id)
          return nil if family_id.blank?

          if configured_custom_field_id = Setting.plugin_redmine_ldap_user_family["family_custom_field"]
            family_id_filter = Net::LDAP::Filter.eq(custom_attributes[configured_custom_field_id],
                                                    family_id.to_s + '*')
          end
          return nil if family_id_filter.nil?

          attrs = []
          # get user's DN
          ldap_con = initialize_ldap_con(self.account, self.account_password)
          object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
          custom_ldap_filter = custom_filter_to_ldap

          if custom_ldap_filter.present?
            search_filters = object_filter & family_id_filter & custom_ldap_filter
          else
            search_filters = object_filter & family_id_filter
          end

          search_attributes = ['dn', self.attr_login, self.attr_firstname, self.attr_lastname, self.attr_mail] + custom_attributes.values
          
          dn = String.new
          ldap_con.search( :base => self.base_dn, 
                           :filter => search_filters,
                           :attributes=> search_attributes) do |entry|
            dn = entry.dn
            attrs = get_user_attributes_from_ldap_entry(entry) if onthefly_register?
            attrs.first[:login] = AuthSourceLdap.get_attr(entry, self.attr_login) if onthefly_register?

          end

          if dn.empty?
            return nil
          else
            logger.debug "DN found for parent/child: #{family_id} #{dn}" if logger && logger.debug?
            return attrs
          end
        rescue  Net::LDAP::LdapError => text
          raise "LdapError: " + text
        end
        
      end
    end
  end
end
