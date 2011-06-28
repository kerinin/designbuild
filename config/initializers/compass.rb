require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets", "compiled"))

Compass::AppIntegration::Rails.initialize!

Rails.configuration.middleware.delete('Sass::Plugin::Rack')
Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Sass::Plugin::Rack')

Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
    :urls => ['/stylesheets/compiled'],
    :root => "#{Rails.root}/tmp/stylesheets")