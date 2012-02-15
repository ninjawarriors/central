# Include the controller files
# Hrm, this pattern's looking familiar
Dir.glob('./controllers/*.rb') do |file|
  require file.gsub(/\.rb/, '')
end
# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./lib/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end