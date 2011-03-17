module TrueWeb
  module Plugins
    module DirectoryFirstSort
      def directory_first_sort
        lambda do |path|
          dir = File.dirname(path)
          [dir.length, dir, File.basename(path)]
        end
      end

      extend self
    end
  end
end
