guard :bundler do
  watch('Gemfile')
end

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^spec/support/(.+)\.rb$}) { "spec" }

  # Rails example
  watch('config/routes.rb') { "spec/routing" }
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('app/controllers/application_controller.rb') { "spec/controllers" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$}) { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"] }
end

guard :teaspoon do
  watch(%r{^spec/javascripts/(.*)})
  watch(%r{^app/assets/javascripts/(.+).js}) { |m| "#{m[1]}_spec" }
end
