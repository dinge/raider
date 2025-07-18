module Raider
  class Railtie < Rails::Railtie
    initializer 'raider.configure_rails_initialization' do
      Rails.autoloaders.main.push_dir("#{Rails.root}/app/raider", namespace: Raider)
    end
  end
end
