require 'spec_helper'
require 'rspec/temp_dir'

describe App do
  include_context 'uses temp dir'

  before(:each) do
    ENV['succotash_conf_path'] = "#{temp_dir}/succotash-test.conf"
  end

  after(:each) do
    File.delete(ENV['succotash_conf_path']) if File.exist?(ENV['succotash_conf_path'])
  end

  def write_file(path, content)
    f = File.new(path, "w+")
    f.write(content.join("\n"))
    f.close
  end

  def add_config(h)
    write_file(ENV['succotash_conf_path'], h.map {|k, v| "#{k.to_s} = #{v}"})
  end

  let(:file_path) {"#{temp_dir}/my_file"}

  context '/add_line' do
    before(:each) {
      add_config({
        file: file_path,
        placeholder: '# Add after here'
      })
    }

    context 'writes to the specified file' do
      it 'adds the line after the placeholder' do
        write_file(file_path, [
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'plic = ploc'
        ])

        get '/add_line?line=Ni!'
        expect(last_response).to be_ok
        expect(last_response.body).to eq("Done :)")
        
        expect(File.new(file_path).read.split("\n")).to eq([
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'Ni!',
          'plic = ploc'
        ])
      end

      it 'when the placeholder is not found, nothing is added' do
        write_file(file_path, [
          '  # Existing stuff here',
          '  stuff = things',
          '  plic = ploc'
        ])

        get '/add_line?line=Ni!'
        expect(last_response).to be_ok
        expect(last_response.body).to eq("Done :)")

        expect(File.new(file_path).read.split("\n")).to eq([
          '  # Existing stuff here',
          '  stuff = things',
          '  plic = ploc'
        ])
      end

      it 'does not mind spaces before/after the placeholder' do
        write_file(file_path, [
          '  # Existing stuff here',
          '  stuff = things',
          '  # Add after here',
          '  plic = ploc'
        ])

        get '/add_line?line=Ni!'
        expect(last_response).to be_ok
        expect(last_response.body).to eq("Done :)")

        expect(File.new(file_path).read.split("\n")).to eq([
          '  # Existing stuff here',
          '  stuff = things',
          '  # Add after here',
          'Ni!',
          '  plic = ploc'
        ])
      end

      it 'adds the line multiple times when the placeholder appears multiple times too' do
        write_file(file_path, [
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'plic = ploc',
          '# Add after here',
          'plic = ploc',
          '# Add after here',
          'plic = ploc',
          '# Add after here',
          'plic = ploc'
        ])

        get '/add_line?line=Ni!'
        expect(last_response).to be_ok
        expect(last_response.body).to eq("Done :)")

        expect(File.new(file_path).read.split("\n")).to eq([
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'Ni!',
          'plic = ploc',
          '# Add after here',
          'Ni!',
          'plic = ploc',
          '# Add after here',
          'Ni!',
          'plic = ploc',
          '# Add after here',
          'Ni!',
          'plic = ploc'
        ])
      end

      it 'updates the file if the correct token is given' do
        write_file(file_path, [
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'plic = ploc'
        ])

        add_config({
          file: file_path,
          placeholder: '# Add after here',
          security_token: 'notZuperZecret'
        })

        get '/add_line?line=Ni!&token=notZuperZecret'
        expect(last_response).to be_ok
        expect(last_response.body).to eq("Done :)")
        
        expect(File.new(file_path).read.split("\n")).to eq([
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'Ni!',
          'plic = ploc'
        ])
      end
    end

    it 'runs the command after updating the file' do
      write_file(file_path, [
        '# Existing stuff here',
        'stuff = things',
        '# Add after here',
        'plic = ploc'
      ])

      add_config({
        file: file_path,
        placeholder: '# Add after here',
        command: "cp #{file_path} #{temp_dir}/copied"
      })

      get '/add_line?line=Ni!'
      expect(last_response.status).to eq(200)

      expect(File.new("#{temp_dir}/copied").read.split("\n")).to eq([
        '# Existing stuff here',
        'stuff = things',
        '# Add after here',
        'Ni!',
        'plic = ploc'
      ])      
    end


    context 'raises an error' do
      it '403 when the security token does not match' do
        write_file(file_path, [
          '# Existing stuff here',
          'stuff = things',
          '# Add after here',
          'plic = ploc'
        ])

        add_config({
          file: file_path,
          security_token: "zuperZekretAch!"
        })

        get '/add_line?line=Ni!'
        expect(last_response.status).to eq(403)
        expect(last_response.body).to eq('Nope!')

        get '/add_line?line=Ni!&token=zuperZekretAch'
        expect(last_response.status).to eq(403)
        expect(last_response.body).to eq('Nope!')
      end

      context '500' do
        it 'when the config file can not be read' do
          get '/add_line'

          expect(last_response.status).to eq(500)
          expect(last_response.body).to eq('Nothing to write to')
        end

        it 'when the file to write does not exist' do
          get '/add_line'

          add_config({
            file: "do not exist"
          })

          expect(last_response.status).to eq(500)
        end
      end
    end
  end
end
