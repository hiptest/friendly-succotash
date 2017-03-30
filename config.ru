#\ -s puma
require "rubygems"
require "dotenv"
Dotenv.load
require "sinatra"
require './app'

run App.new