module AwesomeTree
  class Railtie < Rails::Railtie
    initializer 'awesome-tree' do |app|
      ActiveSupport.on_load :active_record do
        include AwesomeTree::ActiveRecord
      end
    end
  end
end
