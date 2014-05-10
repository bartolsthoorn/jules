module Jules
  module Miners
    class << self
      def zebra_list?(list_items)
        # Use outlines to see if lists are structured like
        # AAAAAA        (stride 0)
        # ABABAB        (stride 1)
        # AABBAABB      (stride 2)
        # AAABBBAAABBB  (stride 3)

        # TODO: Do the following 2 lines in 1 step
        outlines = list_items.map(&:to_outline)
        outlines.map!{ |outline| Nokogiri::XML.remove_markup_outline(outline) }

        # First test for non_zebra AAAAA
        errors = []
        outlines.each_with_index do |outline, i|
          previous_outline =  outlines[i - 1]
          errors << DL.relative(outline, previous_outline)
        end
        avg_error = errors.inject(:+) / errors.size
        stride0_certainty = 1 - avg_error
        if stride0_certainty == 1.0
          return {stride: 0, certainty: stride0_certainty }
        end

        # Not certain it's AAAA, so continue to check for ABABAB
        errors = []
        outlines.each_with_index do |outline, i|
          before_outline   =  outlines[i - 2]
          previous_outline =  outlines[i - 1]
          next_outline =  outlines[i + 1]
          if outlines[i + 1] == nil
            next_outline =  outlines[i % outlines.count - 1]
          end

          if previous_outline && next_outline
            zebra_1 = DL.relative(previous_outline, next_outline)
            zebra_2 = DL.relative(outline, before_outline)
            # zebra should be close to 0.0
            errors << (zebra_1 + zebra_2) / 2
          end
        end
        avg_error = errors.inject(:+) / errors.size
        stride1_certainty = 1 - avg_error
        if stride1_certainty > stride0_certainty
          {stride: 1, certainty: stride1_certainty}
        else
          {stride: 0, certainty: stride0_certainty}
        end
      end

      def unzebrify(result)
        result.each_with_index do |list, r|
          nodes = list[:items].map{ |item| item[:node] }
          zebra = zebra_list?(nodes)

          if zebra[:stride] == 1 && zebra[:certainty] > 0.90
            # Buffer items and restore in different way
            items = list[:items]
            result[r][:items] = []

            # Merge nodes
            items.each_with_index do |item, i|
              joined_item ||= {level: item[:level], node: []}
              joined_item[:node] << item[:node]
              if i.odd?
                result[r][:items] << joined_item
                join_item = nil
              end
            end
          end
        end
        result
      end

      def lists(html)
        depth = html.deepest_level
        result = []

        depth.times do |level|
          xpath = '/*' * (level + 1)
          nodes = html.xpath(xpath)
          items = []
          last_node = nodes.first
          nodes.each do |node|
            next unless [:li, :div, :tr].include? node.name.to_sym

            if items.last && items.last[:node].name != node.name
              # Store items as collection when 2 or more found
              if items.count > 1
                result << {
                  level: level,
                  items: items }
              end
              items = []
            end

            # Node is same element family as previous node
            # But it could still be part of a one multiple node item
            if items.last
              # Is current node different from the previous one?
              if items.last[:node].to_outline != node.to_outline
                # Next node outline same as previous node outline?
              end
            end
            items << {
              titles: Jules::Miners.titles(node),
              node: node,
              text: node.text
            }
          end
          if items.count > 1
            result << {
              level: level,
              items: items }
          end
        end
        unzebrify(result)
      end
    end
  end
end
