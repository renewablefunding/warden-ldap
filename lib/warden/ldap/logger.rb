module Warden
  module Ldap
    class Logger
      class << self
        def info(message)
          STDOUT.puts message
        end

        def error(message)
          STDERR.puts message
        end
      end
    end
  end
end
