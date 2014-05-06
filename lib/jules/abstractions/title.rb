module Jules
  module Abstractions
    class Title
      attr_accessor :level, :text, :language

      def initialize(level, text)
        raise ArgumentError if level.class != Fixnum
        raise ArgumentError if text.class != String

        # H1 means level 1, etc.
        @level = level

        # Name contains the actual title data
        @text = text

        # Language detection
        @language = text.language
      end
    end
  end
end
