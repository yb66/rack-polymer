require "rack/polymer/version"
require "rack/jquery/helpers"

module Rack
  class Polymer
    include Rack::JQuery::Helpers # for caching

    # Namespaced CDNs for convenience.
    module CDN

      # Script tags for the Media Temple CDN
      CLOUDFLARE = "//cdnjs.cloudflare.com/ajax/libs/polymer/#{POLYMER_VERSION}/polymer.min.js"

    end


    # The file name to use for the fallback route.
    POLYMER_FILE_NAME = "polymer-#{POLYMER_VERSION}.min.js"

    # The file name of the source map.
    POLYMER_SOURCE_MAP = "polymer.min.js.map"


    # This javascript checks if the Polymer object has loaded. If not, that most likely means the CDN is unreachable, so it uses the local minified Polymer.
    FALLBACK = <<STR
<script type="text/javascript">
  if (typeof Polymer == 'undefined') {
    document.write(unescape("%3Cscript src='/js/#{POLYMER_FILE_NAME}' type='text/javascript'%3E%3C/script%3E"))
  };
</script>
STR


    # @param [Hash] env The rack env.
    # @param [Hash] opts Extra options.
    # @options opts [Symbol] :organisation Choose which CDN to use. The default is :cloudflare. If an organisation was set via the Rack env this will override it.
    # @options opts [FalseClass] :cdn Mark as false if you *don't* want to use the CDN and only want to use the fallback script. This option is primarily here so I can use the latest script without relying on the CDN, but use it however you wish.
    # @return [String] The HTML script tags to get the CDN.
    # @example
    #   Rack::Polymer.cdn( env )
    #
    #   # Choose an organisation
    #   Rack::Polymer.cdn( env, organisation: :cloudflare )
    #
    #   # Don't use a CDN, just use the fallback
    #   Rack::Polymer.cdn( env, cdn: false )
    def self.cdn( env, opts={} )
      organisation =  opts[:organisation] ||
                        (env["rack.polymer"] && env["rack.polymer"]["organisation"]) ||
                        Rack::Polymer::DEFAULT_ORGANISATION

      script = case organisation
        when :cloudflare then CDN::CLOUDFLARE
        else CDN::CLOUDFLARE
      end

      opts[:cdn] == false ?
        FALLBACK :
        "<script src='#{script}'></script>\n#{FALLBACK}"
    end


    # The default CDN to use.
    DEFAULT_ORGANISATION = :cloudflare


    # Default options hash for the middleware.
    DEFAULT_OPTIONS = {
      :http_path => "/js",
      :organisation => DEFAULT_ORGANISATION
    }


    # @param [#call] app
    # @param [Hash] options
    # @option options [String] :http_path If you wish the Polymer fallback route to be "/js/polymer-0.0.20130711.min.js" (or whichever version this is at) then do nothing, that's the default. If you want the path to be "/assets/javascripts/polymer-0.0.20130711.min.js" then pass in `:http_path => "/assets/javascripts".
    # @option options [Symbol] :organisation Choose which CDN to use. The default is :cloudflare.
    # @example
    #   # The default:
    #   use Rack::Polymer
    #
    #   # With a different route to the fallback:
    #   use Rack::Polymer, :http_path => "/assets/js"
    #
    #   # With the CDN specified via the use statement
    #   use Rack::Polymer, :organisation => :cloudflare
    def initialize( app, options={} )
      @app, @options  = app, DEFAULT_OPTIONS.merge(options)
      @http_path_to_polymer, @http_path_to_polymer_source_map =
        [POLYMER_FILE_NAME,POLYMER_SOURCE_MAP].map{|file_name|
          ::File.join @options[:http_path], file_name
        }
      @organisation = @options[:organisation]
    end


    # @param [Hash] env Rack request environment hash.
    def call( env )
      dup._call env
    end


    # For thread safety
    # @param (see #call)
    def _call( env )
      env.merge! "rack.polymer" => {"organisation" => @organisation}

      request = Rack::Request.new(env.dup)
      if request.path_info == @http_path_to_polymer
        @response = Rack::Response.new
        # for caching
        @response.headers.merge! caching_headers( POLYMER_FILE_NAME, POLYMER_VERSION_DATE)

        # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
        if request.env['HTTP_IF_MODIFIED_SINCE']
          @response.status = 304
        else
          serve_static_file "polymer.min.js"
        end
        @response.finish
      elsif request.path_info == @http_path_to_polymer_source_map
        # The source map isn't cached
        serve_static_file( "polymer.min.js.map" ).finish
      else
        @app.call(env)
      end
    end # call


    # Helper method for serving static files.
    # @param [String] file The short file name.
    # @return [Rack::Response]
    def serve_static_file( file )
      @response ||= Rack::Response.new
      @response.status = 200
      @response.write ::File.read( ::File.expand_path "../../../vendor/assets/javascript/libs/polymer/#{POLYMER_VERSION}/#{file}", __FILE__)
      @response
    end      

  end
end
