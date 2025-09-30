# frozen_string_literal: true

module Raider
  module Utils
    class CallerProxy
      def initialize(caller, to:)
        @caller = caller
        @to = to
      end

      def method_missing(method_name, **args, &proc)
        @caller.send(@to, method_name, **args, &proc).context.to_h
      end
    end
  end
end
