# TODO: Support identifier, active record object (and ids?) for all role methods?

module AwesomeTree
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def awesome_treeify
        include InstanceMethods
          has_secure_password
          has_and_belongs_to_many :roles

          validates :password, presence: {on: :create}, confirmation: true, length: {minimum: 6}, allow_blank: true,  reduce: true
          validates :email, presence: true, uniqueness: true, email: {allow_blank: true}, reduce: true
          validates :password_confirmation, presence: true, if: Proc.new { |p| ! p.password.blank? }, reduce: true

          after_update :deliver_password_reset_notification

          scope :root, -> { where(parent_id: nil) }
      end

      module InstanceMethods
        # Ancestors
        def ancestors
          self_and_ancestors - [self]
        end
        def self_and_ancestors
          self.class.self_and_ancestors_for(self)
        end

        # Descendents
        def descendents
          self_and_descendents - [self]
        end
        def self_and_descendents
          self.class.self_and_descendents_for(self)
        end

        # Check if ancestors, self_and_ancestors, descendents or self_and_descendents includes role?
        def method_missing(method, *args, &block)
          if method.to_s =~ /^(.+)_includes\?$/
            self.send($1.to_sym).include? *args.first
          else
            super
          end
        end

        private
          # Ancestors
          def self.self_and_ancestors_for(instance)
            where("#{table_name}.id IN (#{self_and_ancestors_sql_for(instance)})")
          end
          def self.self_and_ancestors_sql_for(instance)
            tree_sql =  <<-SQL
              WITH RECURSIVE search_tree(id, parent_id, path) AS (
                  SELECT id, parent_id, ARRAY[id]
                  FROM #{table_name}
                  WHERE id = #{instance.id}
                UNION ALL
                  SELECT #{table_name}.id, #{table_name}.parent_id, path || #{table_name}.id
                  FROM search_tree
                  JOIN #{table_name} ON #{table_name}.id = search_tree.parent_id
                  WHERE NOT #{table_name}.id = ANY(path)
              )
              SELECT id FROM search_tree ORDER BY path DESC
            SQL
          end

          # Descendents
          def self.self_and_descendents_for(instance)
            where("#{table_name}.id IN (#{self_and_descendents_sql_for(instance)})")
          end
          def self.self_and_descendents_sql_for(instance)
            tree_sql =  <<-SQL
              WITH RECURSIVE search_tree(id, path) AS (
                  SELECT id, ARRAY[id]
                  FROM #{table_name}
                  WHERE id = #{instance.id}
                UNION ALL
                  SELECT #{table_name}.id, path || #{table_name}.id
                  FROM search_tree
                  JOIN #{table_name} ON #{table_name}.parent_id = search_tree.id
                  WHERE NOT #{table_name}.id = ANY(path)
              )
              SELECT id FROM search_tree ORDER BY path
            SQL
          end
      end # InstaceMethods
    end # ClassMethods

  end # ActiveRecord
end # AwesomeTree







