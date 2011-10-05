require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require 'pp'
require 'ruby-debug'

require 'active_support/all'
require 'evma_httpserver'

module XedniServer
  module Views
    VIEW_DIR = "./views"
    def self.method_missing(*args)
      filename = args.shift.to_s
      template = File.read(File.join(VIEW_DIR, filename))
      haml_engine = Haml::Engine.new(template)
      haml_engine.render
    end
  end
  # Here is where we route the actions
  module Router
    ROUTES = {
      /^\/$/ => {:get=>:index, :post=>:index, :delete=>:index, :put => :index },
      /^\/create$/ => :create,
      /^\/update$/ => :update,
      /^\/read$/   => :read
    }

    @routes = {}
    def self.route(action,uri)
      if @routes[uri]
        @routes[uri]
      else
        match = ROUTES.find(lambda{ [/.*/, :not_found]}) do |r|
          r.first =~ uri ? r : nil
        end

        matched_url = if match.second.is_a?(Hash)
            match.second[action.to_s.downcase.to_sym] || :not_found
          else
            match.second
          end
        @routes[uri] = matched_url
      end
    end
  end

  # Here is where we handle the actions
  module Actions
    def self.not_found(resp)
      resp.status = 200
      resp.content_type 'text/html'
      resp.content = XedniServer::Views.not_found
      resp.send_response
    end
    def self.index(resp)
      resp.status = 200
      resp.content_type 'text/html'
      resp.content = XedniServer::Views.index
      resp.send_response
    end
    def self.query(resp)
      # TODO -- If flagged for syncronous - do it now.
      #    otherwise defer
      EventMachine.defer(proc {
        puts "Calling Xedni::Query..."
        sleep 2
        puts "Called Xedni::Query"
      },
        proc {|result|
          resp.status = 123
          resp.send_response
        }
      )
    end
    def self.read(resp)
      # TODO -- If flagged for syncronous - do it now.
      #    otherwise defer
      EventMachine.defer(proc {
        puts "*"*1000
        puts "Calling Xedni::Read..."
        sleep 1
        puts "Called Xedni::Read"
      },
        proc {|result|
          resp.status=123
          resp.send_response
        }
      )
    end
    def self.create(resp)
      resp.status = 123
      resp.send_response
      puts "Send response"

      # TODO -- If flagged for syncronous - do it now.
      #    otherwise defer
      EventMachine.defer(proc {
        puts "Calling Xedni::Create..."
        sleep 1
        puts "Called Xedni::Create"
      },
        proc {|result|
        }
      )
    end

    def self.update(resp)
      resp.status = 123
      resp.send_response
      puts "Send response"

      # TODO -- If flagged for syncronous - do it now.
      #    otherwise defer
      EventMachine.defer(proc {
        puts "Calling Xedni::Update..."
        sleep 1
        puts "Called Xedni::Update"
      },
        proc {|result|
        }
      )
    end
    def self.destroy
      resp.status = 123
      resp.send_response
      puts "Send response"

      # TODO -- If flagged for syncronous - do it now.
      #    otherwise defer
      EventMachine.defer(proc {
        puts "Calling Xedni::Destroy..."
        sleep 1
        puts "Called Xedni::Destroy"
      },
        proc {|result|
        }
      )
    end
  end

  # Here is the App
  class App < EM::Connection
    include EM::HttpServer
    def post_init
      super
      @@routes = {}
      no_environment_strings
    end

    def process_http_request
      # the http request details are available via the following instance variables:
      #   @http_protocol
      #   @http_request_method
      #   @http_cookie
      #   @http_if_none_match
      #   @http_content_type
      #   @http_path_info
      #   @http_request_uri
      #   @http_query_string
      #   @http_post_content
      #   @http_headers

      action = XedniServer::Router.route(@http_request_method, @http_request_uri)
      response = EM::DelegatedHttpResponse.new(self)
      XedniServer::Actions.send(action, response)


      # Parse the http request
      # match it against simple regex matches
      # handle the request
      # return
    end
  end
end
EventMachine::run do
  host = '0.0.0.0'
  port = 11456
  EventMachine::start_server host, port, XedniServer::App
  puts "Started Xedni on #{host}:#{port}"
end
