module OpenProject::GlobalRoles::Patches
  module RolePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)


      base.class_eval do
        scope :givable, where(:builtin => 0, :type => 'Role').order('position')

        class << self
          alias_method :find_all_givable_without_no_global_roles, :find_all_givable unless method_defined?(:find_all_givable_without_no_global_roles)
          alias_method :find_all_givable, :find_all_givable_with_no_global_roles
        end

        alias_method_chain :setable_permissions, :no_global_roles
      end
    end

    module ClassMethods
      def find_all_givable_with_no_global_roles
        givable.all
      end
    end

    module InstanceMethods
      def setable_permissions_with_no_global_roles
        setable_permissions = setable_permissions_without_no_global_roles
        setable_permissions -= Redmine::AccessControl.global_permissions
        setable_permissions
      end
    end
  end
end

Role.send(:include, OpenProject::GlobalRoles::Patches::RolePatch)