module Jules
  module Miners
    class << self
      def titles(html)
        titles = []

        10.times do |i|
          level = i + 1
          html.xpath('.//h' + level.to_s).each do |title|
            name = title.text
            titles << Jules::Abstractions::Title.new(level, name)
          end
        end

        titles
      end
    end
  end
end
