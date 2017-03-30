require 'parseconfig'
require 'sinatra/base'

class App < Sinatra::Application
  get '/add_line' do
    config = ParseConfig.new('succotash.conf')
    return unless config.params['security_token'] == params[:token]

    content = []
    File.open(config.params['file']).each do |line|
      content << line
      if line.strip == config.params['placeholder']
        content << "#{params[:line]}\n"
      end
    end

    File.write(config.params['file'], content.join(""))
    `#{config.params['command']}` unless config.params['command'].nil?

    "Done :)"
  end
end
