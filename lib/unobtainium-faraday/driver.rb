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

          # TODO: add SSL configuration stuff

          return normalize_label(label), opts
        end

        ##
        # Create and return a driver instance
        def create(_, options)
          driver = ::Unobtainium::Faraday::Driver.new(options)
          return driver
        end
      end # class << self

      ##
      # Map any missing method to nokogiri
      def respond_to?(meth)
        if not @conn.nil? and @conn.respond_to?(meth)
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
    __FILE__)
