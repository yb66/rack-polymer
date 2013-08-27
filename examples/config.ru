require "rubygems"
require "bundler"
Bundler.setup(:examples)
require File.expand_path( '../config.rb', __FILE__)

map "/specified-via-use" do
  run App2
end

run App