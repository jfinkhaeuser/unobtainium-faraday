# coding: utf-8
#
# unobtainium-faraday
# https://github.com/jfinkhaeuser/unobtainium-faraday
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-faraday contributors.
# All rights reserved.
#

require 'unobtainium'
require 'unobtainium/support/util'
require 'unobtainium/pathed_hash'

module Unobtainium
  ##
  # Faraday namespace
  module Faraday

    ##
    # Driver implementation using faraday (and open-uri).
    class Driver
      # Recognized labels for matching the driver
      LABELS = {
        faraday: [:api,],
      }.freeze

      # @private
      # Default options to pass to Faraday
      DEFAULT_OPTIONS = PathedHash.new(
        connection: {
          request: [:multipart, :json],
          response: [
            [:xml, content_type: /\bxml$/],
            [:json, content_type: /\bjson$/],
          ],
        }
      ).freeze

      class << self
        include ::Unobtainium::Support::Utility

        ##
        # Return true if the given label matches this driver implementation,
        # false otherwise.
        def matches?(label)
          return nil != normalize_label(label)
        end

        ##
        # Ensure that the driver's preconditions are fulfilled.
        def ensure_preconditions(_, _)
          require 'faraday'
          require 'faraday_middleware'
          require 'faraday_json'
        rescue LoadError => err
          raise LoadError, "#{err.message}: you need to add "\
                "'faraday', 'faraday_middleware' and 'faraday_json' to your "\
                "Gemfile to use this driver!",
                err.backtrace
        end

        ##
        # Mostly serves to populate options with default options.
        def resolve_options(label, options)
          # Start with sensible defaults
          opts = {}
          if not options.nil?
            opts = options.dup
          end
          opts = DEFAULT_OPTIONS.recursive_merge(opts)

          # For SSL options, if 'client_key' and 'client_cert' are
          # 1) Strings that name files, then the file contents are substituted, and
          # 2) Strings that are certificates/private keys, then they are parsed
          resolve_ssl_option(opts, 'ssl.client_cert',
                             /BEGIN CERTIFICATE/,
                             ::OpenSSL::X509::Certificate)
          resolve_ssl_option(opts, 'ssl.client_key',
                             /BEGIN (EC|DSA|RSA| *) ?PRIVATE KEY/,
                             ::OpenSSL::PKey, 1)

          return normalize_label(label), opts
        end

        ##
        # Create and return a driver instance
        def create(_, options)
          driver = ::Unobtainium::Faraday::Driver.new(options)
          return driver
        end

        ##
        # Helper function for resolve_options for resolving SSL options
        def resolve_ssl_option(opts, path, pattern, klass, match_index = 0)
          # Ignore if the path doesn't exist
          if opts.nil? or opts[path].nil?
            return
          end

          # Skip if the path isn't a String. We assume it's already been
          # processed. Either way, faraday can take care of it.
          val = opts[path]
          if not val.is_a? String
            return
          end

          # If the string represents a file name, read the file! Any errors with
          # that should go through to the caller.
          if File.file?(val)
            val = File.read(val)
          end

          # If the value doesn't match the given pattern, that seems like an
          # error.
          match = val.match(pattern)
          if not match
            raise ArgumentError, "Option '#{path}' does not appear to be valid, "\
                  "as it does not match #{pattern}."
          end

          # Finally, we can pass the value on to OpenSSL/the klass. Make that
          # dependent on what class klass actually is.
          case klass
          when Class
            val = klass.new(val)
          when Module
            name = match[match_index]
            if name.nil? or name.empty?
              name = 'RSA'
            end
            name = '::' + klass.name + '::' + name
            val = Object.const_get(name).new(val)
          end

          # Overwrite the options!
          opts[path] = val
        end
      end # class << self

      ##
      # Map any missing method to nokogiri
      def respond_to_missing?(meth, include_private = false)
        if not @conn.nil? and @conn.respond_to?(meth, include_private)
          return true
        end
        return super
      end

      ##
      # Map any missing method to nokogiri
      def method_missing(meth, *args, &block)
        if not @conn.nil? and @conn.respond_to?(meth)
          return @conn.send(meth.to_s, *args, &block)
        end
        return super
      end

      attr_accessor :conn

      private

      ##
      # Private initialize to force use of Driver#create.
      def initialize(opts)
        @options = opts.dup

        # Extract URI, if it exists. This will be passed as a parameter to
        # faraday.
        uri = @options.fetch(:uri, nil)
        @options.delete(:uri)

        # Extract connection configuration
        connection = @options.fetch(:connection, {})
        @options.delete(:connection)

        # Supplement connection configuration with the default adapter, if
        # necessary.
        if connection[:adapter].nil?
          connection[:adapter] = ::Faraday.default_adapter
        end

        # Create connection object
        @conn = ::Faraday.new(uri, @options) do |faraday|
          # Pass adapter configurations to faraday
          connection.each do |type, params|
            p = params
            if not params.is_a? Array
              p = [params]
            end

            p.each do |args|
              faraday.send(type, *args)
            end
          end
        end
      end
    end # class Driver

  end # module Faraday
end # module Unobtainium

::Unobtainium::Driver.register_implementation(
    ::Unobtainium::Faraday::Driver,
    __FILE__
)
