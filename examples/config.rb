require 'sinatra/base'
require 'haml'
require 'rack/polymer'

class App < Sinatra::Base

  enable :inline_templates
  use Rack::Polymer

  get "/" do
    output = <<STR
!!!
%body
  %ul
    %li
      %a{ href: "/cloudflare-cdn"} cloudflare-cdn
    %li
      %a{ href: "/unspecified-cdn"} unspecified-cdn
    %li
      %a{ href: "/specified-via-use"} specified-via-use
STR
    haml output
  end

  get "/cloudflare-cdn" do
    haml :index, :layout => :cloudflare
  end

  get "/unspecified-cdn" do
    haml :index, :layout => :unspecified
  end
end


# This is probably the one I'd use.
class App2 < Sinatra::Base

  enable :inline_templates
  use Rack::Polymer, :organisation => :cloudflare

  get "/" do
    haml :index, :layout => :specified_via_use
  end
end

__END__

@@cloudflare
!!!
%head
  = Rack::Polymer.cdn( env, :organisation => :cloudflare )
%body
  = yield

@@unspecified
!!!
%head
  = Rack::Polymer.cdn(env)
%body
  = yield

@@specified_via_use
!!!
%head
  = Rack::Polymer.cdn(env)
%body
  = yield

@@index
%h1
  No specs for this yet
%p
  Something to test will appear soon, I need to work out what's testable first.