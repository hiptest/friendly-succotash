require 'parseconfig'
require 'sinatra/base'

class App < Sinatra::Application
  get '/add_line' do
    config = ParseConfig.new('succotash.conf')

    content = []
    File.open(config.params['file']).each do |line|
      content << line
      if line.strip == config.params['placeholder']
        content << "#{params[:line]}\n"
      end
    end

    File.write(config.params['file'], content.join(""))
  end
end
