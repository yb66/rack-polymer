# Rack::Polymer #

[Polymer](http://www.polymer-project.org/) CDN script tags and fallback in one neat package. Current version is for Polymer v#{Rack::Polymer::POLYMER_VERSION}

### Build status ###

Master branch:
[![Build Status](https://travis-ci.org/yb66/rack-polymer.png?branch=develop)](https://travis-ci.org/yb66/rack-polymer)


## Why? ##

Because then I don't have to worry about versioning or fallback.

## Installation ##

Add this line to your application's Gemfile:

    gem 'rack-polymer'

And then, from a command-line, execute:

    bundle install

Or even better:

    bundle install --binstubs --path vendor

Or install it yourself as:

    gem install rack-polymer -r

## Usage ##

In your rackup file or Sinatra class (or wherever you like to set up Rack middleware…)

    use Rack::Polymer

Then wherever you need the script loaded (like in a layout file):

    Rack::Polymer.cdn( env )

That's it. There are more options, check the docs.


### Version numbers ###

This library uses [semver](http://semver.org/) to version the **library**. That means the library version is ***not*** an indicator of quality but a way to manage changes. The version of Polymer can be found in the lib/rack/polymer/version.rb file, or via the {Rack::Polymer::POLYMER_VERSION} constant.

On top of that, version numbers will also change when new releases of Polymer are supported.

* If Polymer makes a major version jump, then this library will make a ***minor*** jump. That is because the API for the library has not really changed, but it is *possibly* a change that will break things.
* If Polymer makes a minor version jump, then so will this library, for the same reason as above.
* I doubt point releases will be followed, but if so, it will also precipitate a minor jump in this library's version number. That's because even though Polymer feel it's a point release, I'm not them, my responsibility is to users of this library and I'll take the cautious approach of making it a minor version number change.

As an example, if the current library version was 1.0.0 and Polymer was at 2.0.0 and I made a change that I felt was major and breaking (to the Ruby library), I'd bump Rack::Polymer's version to 2.0.0. That the version numbers match between Rack::Polymer and the Polymer script is of no significance, it's just coincidental.  
If then Polymer went to v2.1.0 and I decided to support that, I'd make the changes and bump Rack::Polymer's version to 2.1.0. That the version numbers match between Rack::Polymer and the Polymer script is of no significance, it's just coincidental.  
If then I made a minor change to the library's API that could be breaking I'd bump it to 2.2.0.  
If I then added some more instructions I'd bump Rack::Polymer's version to 2.2.1.  
If then Polymer released version 3.0.0, I'd add it to the library, and bump Rack::Polymer's version to 2.3.0.

Only one version of Polymer will be supported at a time. This is because the fallback script is shipped with the gem and I'd like to keep it as light as possible. It's also a headache to have more than one.

So basically, if you want to use a specific version of Polymer, look for the library version that supports it via the {Rack::Polymer::POLYMER_VERSION} constant. Don't rely on the version numbers of *this* library to tell you anything other than compatibility between versions of this library.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
