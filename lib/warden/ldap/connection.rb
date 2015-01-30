require 'yaml'

module Warden
  module Ldap
    class Connection
      attr_reader :ldap, :login, :host_addresses
      def logger
        Warden::Ldap.logger
      end

      # @public
      # Uses the warden_ldap.yml file to initialize the net-ldap connection.
      #
      # Inputs:
      #   options
      #     :username: username to use for logging in
      #     :password: password to use for logging in
      #     :encryption: 'ssl' will use secure server
      #
      def initialize(options= {})
        @login = options.delete(:username)
        @password = options.delete(:password)

        options[:encryption] = config["ssl"].to_sym if config["ssl"]

        set_host_addresses

        @ldap = Net::LDAP.new(options)
        @ldap.host = host_addresses.first
        @ldap.port = config["port"]
        @ldap.base = config["base"]

        @generic_credentials = config["generic_credentials"]
        @attribute = [config["attributes"]].flatten
      end

      # @public
      # searchs LDAP directory for the parameters value passed in, e.g., 'cn'.
      #
      # Input:
      #   param: key to look for
      # Output:
      #   value if found
      #   nil otherwise
      #
      def ldap_param_value(param)
        ldap_entry = nil
        @ldap.search(:filter => ldap_username_filter) {|entry| ldap_entry = entry}

        if ldap_entry
          value = ldap_entry.send(param)
          logger.info("Requested param #{param} has value #{value}")
          value = value.first if value.is_a?(Array) and value.count == 1
        else
          logger.error("Requested ldap entry does not exist")
          value = nil
        end
      rescue NoMethodError => e
        logger.error("Requested param #{param} does not exist")
        nil
      end

      # @public
      # performs authentication with LDAP
      #
      # Output:
      #  true if authentication was succcessful
      #  false otherwise
      #  nil if password was not provided
      #
      def authenticate!
        result, count, length  = [ nil, 0, host_addresses.length ]

        while count < length * 2
          begin
            logger.info("Attempting LDAP connect with host #{@ldap.host}.")
            Timeout::timeout(config.fetch('timeout', 5).to_i) { result = connect! }
            break
          rescue Errno::ETIMEDOUT, Timeout::Error => e
            logger.error("Requested host timed out: #{@ldap.host}; trying again with new host.")
            count += 1
            @ldap.host = host_addresses[count % length]
          end
        end

        result
      end

      # @public
      # Predicate for determining if the user is authenticated
      #
      def authenticated?
        authenticate!
      end

      # @public
      # searches ldap directory for login name.
      #
      # Output:
      #   true if found
      #   false otherwise
      #
      def valid_login?
        !search_for_login.nil?
      end

      private
      # @private
      def connect!
        if @password
          @ldap.auth(dn, @password)
          @ldap.bind
        end
      end

      # @private
      # sets @host_addresses to an array of ip addresses
      def set_host_addresses
        @host_addresses = Resolv::DNS.open { |dns|
          dns.getresources(config['host'], Resolv::DNS::Resource::IN::SRV)
            .map(&:target)
            .map(&:to_s)
        }
      end

      def ldap_host
        @ldap.host
      end

      # @private
      # Searches the LDAP for the login
      #
      # @return [Object] the LDAP entry found; nil if not found
      def search_for_login
        logger.info("LDAP search for login: #{@attribute}=#{@login}")
        ldap_entry = nil
        @ldap.auth(*@generic_credentials)
        @ldap.search(:filter => ldap_username_filter) {|entry| ldap_entry = entry}
        ldap_entry
      end

      # @private
      def ldap_username_filter
        filters = @attribute.map { |att| Net::LDAP::Filter.eq(att, @login) }
        filters.inject { |a,b| Net::LDAP::Filter.intersect(a, b) }
      end

      # @private
      def find_ldap_user(ldap)
        logger.info("Finding user: #{dn}")
        ldap.search(:base => dn, :scope => Net::LDAP::SearchScope_BaseObject).try(:first)
      end

      # @private
      def config
        if File.exists?(Warden::Ldap.config_file.to_s)
          @config = YAML.load_file(Warden::Ldap.config_file.to_s)[Warden::Ldap.env]
        else
          {}
        end
      end

      # @private
      def dn
        logger.info("LDAP dn lookup: #{@attribute}=#{@login}")

        if ldap_entry = search_for_login
          ldap_entry.dn
        end
      end
    end
  end
end
