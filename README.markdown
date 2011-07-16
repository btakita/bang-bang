# TrueWeb

TrueWeb is a lightweight Sinatra web VC stack. Currently, it doesn't have strong opinions, to allow flexibility to discover good idioms.

## Basic Layout

TrueWeb has a basic app structure, similar to Rails.
Right now, no conventions are "forced" on you. This is done to allow experimentation and keep things lightweight.

You pick the model library.

Right now there are no generators.

### TrueWeb::Controller

TrueWeb::Controller is a subclass of Sinatra::Base.
It's meant to provide an encapsulated unit of functionality within your app.
How you group your actions is up to you.

### NamedRoutes

TrueWeb uses the [named-routes](https://github.com/btakita/named-routes) library.

Here is a good pattern to follow:

    module MyApp
      Controller.define_routes do
        def root; end
        get path(:root, "/") do
          "Hello World!"
        end

        def about_us; end
        get path(:about_us, "/about-us") do
          view("/about-us.html.ms")
        end
      end
    end

Defining the route methods allows certain code editors & ides to locate the definition of action.

    uris.about_us # /about-us
