module Warden
  module Ldap
    class Connection
      attr_reader :ldap, :login

      def initialize(params = {})
        return
        ldap_config = YAML.load(ERB.new(File.read("#{Rails.root}/config/ldap.yml")).result)[Rails.env]
        ldap_options = params
        ldap_config["ssl"] = :simple_tls if ldap_config["ssl"] === true
        ldap_options[:encryption] = ldap_config["ssl"].to_sym if ldap_config["ssl"]

        @ldap = Net::LDAP.new(ldap_options)
        @ldap.host = ldap_config["host"]
        @ldap.port = ldap_config["port"]
        @ldap.base = ldap_config["base"]

        @generic_credentials = ldap_config["generic_credentials"]

        @attribute = [ldap_config["attributes"]].flatten
        @ldap_auth_username_builder = params[:ldap_auth_username_builder]

        @group_base = ldap_config["group_base"]

        @login = params[:username]
        @password = params[:password]
      end

      def dn
        Rails.logger.info("LDAP dn lookup: #{@attribute}=#{@login}")
        ldap_entry = search_for_login
        if ldap_entry.nil?

        else
          ldap_entry.dn
        end
      end

      def ldap_username_filter
        filters = @attribute.map { |att| Net::LDAP::Filter.eq(att, @login) }
        filters.inject { |a,b| Net::LDAP::Filter.intersect(a, b) }
      end

     def ldap_param_value(param)
       ldap_entry = nil
       @ldap.search(:filter => ldap_username_filter) {|entry| ldap_entry = entry}

       if ldap_entry
         if ldap_entry[param]
           Rails.logger.info("Requested param #{param} has value #{ldap_entry.send(param)}")
           value = ldap_entry.send(param)
           value = value.first if value.is_a?(Array) and value.count == 1
         else
           Rails.logger.info("Requested param #{param} does not exist")
           value = nil
         end
       else
         Rails.logger.info("Requested ldap entry does not exist")
         value = nil
       end
      end

      def authenticate!
        return
        if @password.present?
          @ldap.auth(dn, @password)
          @ldap.bind
        end
      end

      def authenticated?
        authenticate!
      end

      def authorized?
        Rails.logger.info("Authorizing user #{dn}")
        authenticated?
      end

      def valid_login?
        !search_for_login.nil?
      end

      # Searches the LDAP for the login
      #
      # @return [Object] the LDAP entry found; nil if not found
      def search_for_login
        Rails.logger.info("LDAP search for login: #{@attribute}=#{@login}")
        ldap_entry = nil
        @ldap.auth(*@generic_credentials)
        @ldap.search(:filter => ldap_username_filter) {|entry| ldap_entry = entry}
        ldap_entry
      end

      private

      def find_ldap_user(ldap)
        Rails.logger.info("Finding user: #{dn}")
        ldap.search(:base => dn, :scope => Net::LDAP::SearchScope_BaseObject).try(:first)
      end
    end


  end
end
