require 'parseconfig'
require 'sinatra/base'

class App < Sinatra::Application
  get '/add_line' do
    config = ParseConfig.new(ENV['succotash_conf_path'] || 'succotash.conf')
    unless config.params['security_token'] == params[:token]
      status 403
      body "Nope!"
      return
    end

    unless File.exist?(config.params['file'])
      status 500
      body 'Nothing to write to'
      return
    end

    content = []
    File.open(config.params['file']).each do |line|
      content << line
      content << "\n" unless line.end_with?("\n")

      if line.strip == config.params['placeholder']
        content << "#{params[:line]}\n"
      end
    end

    File.write(config.params['file'], content.join(""))
    `#{config.params['command']}` unless config.params['command'].nil?

    body "Done :)"
  end

  # Stolen from Jgagny's answer here:
  # http://stackoverflow.com/questions/19523889/sinatra-terminate-server-from-request
  post '/terminate' do
    body "I'll be back..."
    # maybe clean things up here...
    logger.info "Received terminate request!"
    Thread.new { sleep 1; Process.kill 'INT', Process.pid }
    halt 200
  end
end
