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
    %li
      %a{ href: "/no-cdn"} no-cdn
STR
    haml output
  end

  get "/cloudflare-cdn" do
    haml :index, :layout => :cloudflare
  end

  get "/unspecified-cdn" do
    haml :index, :layout => :unspecified
  end

  get "/no-cdn" do
    haml :index, :layout => :no_cdn
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


@@ cloudflare
!!!
%head
  = Rack::Polymer.cdn( env, :organisation => :cloudflare )
  %link{ rel: "import", href: "x-foo.html" }
%body
  = yield

@@ unspecified
!!!
%head
  = Rack::Polymer.cdn(env)
  %link{ rel: "import", href: "x-foo.html" }
%body
  = yield

@@ specified_via_use
!!!
%head
  = Rack::Polymer.cdn(env)
  %link{ rel: "import", href: "x-foo.html" }
%body
  = yield


@@ no_cdn 
!!!
%head
  = Rack::Polymer.cdn(env, cdn: false)
  %link{ rel: "import", href: "x-foo.html" }
%body
  = yield

@@index
%p The polymer-all/polymer/workbench/oldSmoke/x-foo.html should be imported below.
<x-foo></x-foo>