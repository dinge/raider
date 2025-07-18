# frozen_string_literal: true

module Raider
  module Utils
    class BaseContext < RecursiveOpenStruct
      def inspect
        JSON.pretty_generate(self.class.name => to_hash)
      end

      alias to_s inspect
    end
  end
end
