# frozen_string_literal: true

module Raider
  module Utils
    class BaseContext < RecursiveOpenStruct
#      include Enumerable

      def inspect
        JSON.pretty_generate(self.class.name => to_hash)
      end

      alias to_s inspect

      # def each(&block)
      #   block.call(@table)
      # end

      def merge!(new_hash)
        @table.merge!(new_hash)
      end
    end
  end
end
