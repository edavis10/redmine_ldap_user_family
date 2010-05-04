module RedmineLdapUserFamily
  module Patches
    module UsersControllerPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          def show
            @user = User.find(params[:id])
            @custom_values = @user.custom_values
            
            # show only public projects and private projects that the logged in user is also a member of
            @memberships = @user.memberships.select do |membership|
              membership.project.is_public? || (User.current.member_of?(membership.project))
            end
            
            events = Redmine::Activity::Fetcher.new(User.current, :author => @user).events(nil, nil, :limit => 10)
            @events_by_day = events.group_by(&:event_date)

            # Removed check for visible users
            render :layout => 'base'

          rescue ActiveRecord::RecordNotFound
            render_404
          end
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
