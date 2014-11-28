require 'jules/version'
require 'nokogiri'
require 'simhash'
require 'descriptive_statistics'

require 'nokogiri/sugar'
require 'enumerable/sugar'
require 'simhash/sugar'

module Jules
  SIMILARITY_THRESHOLD =  0.6
  SIMHASH_BITLENGTH =     128
  ELEMENTS = ['div', 'li', 'tr', 'article']

  def self.collect(html, filters, elements=Jules::ELEMENTS)
    unless html.is_a?(String) || html.is_a?(File)
      raise ArgumentError, 'html not a String or File'
    end

    raise ArgumentError, 'filters argument empty' if filters.nil?
    raise ArgumentError, 'filters not a Hash' unless filters.is_a? Hash
    raise ArgumentError, 'elements not an Array' unless elements.is_a? Array

    document =  Nokogiri::HTML(html)
    trees =     Jules.rearrange_trees(document, elements)
    clusters =  Jules.cluster_trees(trees)
    clusters =  Jules.grade_clusters(clusters, filters)
    Jules.items(clusters, filters)
  end

  # Rearranges DOM trees with Simhash
  def rearrange_trees(document, elements=Jules::ELEMENTS)
    trees = []
    document_length = document.inner_html.length
    xpath = elements.map{ |x| '//' + x }.join('|')
    document.search(xpath).each do |tree|
      structure = Nokogiri::XML.remove_markup_outline(tree.to_outline).strip
      if structure.empty?
        tree.remove # This HTML tree does not contain any structure
        next
      end

      # Tree should be smaller than 50% of document size
      next if (tree.inner_html.length / document_length.to_f * 100) > 50

      trees << {
        node:  tree,
        depth: tree.depth,
        simhash: structure.simhash(hashbits: Jules::SIMHASH_BITLENGTH),
        index:   tree.xpath('count(preceding-sibling::*)').to_i
      }
    end
    trees.sort_by { |tree| tree[:simhash] }
  end
  module_function :rearrange_trees

  # Cluster trees based on similarity
  def cluster_trees(trees)
    clusters, cluster = [], [trees[0]]

    trees.each_with_previous do |prev, tree|
      next if prev.nil? # first item
      similarity = Simhash.similarity(prev[:simhash], tree[:simhash])
      if similarity < Jules::SIMILARITY_THRESHOLD
        clusters << cluster
        cluster = [tree]
      else
        cluster << tree
      end
    end
    clusters << cluster if cluster.count > 0

    # Reject clusters that only contain 1 tree
    clusters.reject { |cluster| cluster.count < 2 }
  end
  module_function :cluster_trees

  # Grade clusters
  def grade_clusters(clusters, filters)
    # Map trees inside cluster hash, to make room for metadata
    clusters.map! {|cluster| {trees: cluster} }

    clusters.each do |cluster|
      cluster[:score] = 0
      cluster[:trees].each do |tree|
        tree = filter_item(tree, filters)

        cluster[:score] += tree[:item].to_h.count
      end
      cluster[:items] = cluster[:trees]
        .sort_by { |tree| tree[:index] }
        .map {     |tree| tree[:item] }
        .reject {  |item| item.nil? }

      # Bonus points if all trees are at same depth
      depth_sd = cluster[:trees].map { |tree| tree[:depth] }.standard_deviation
      cluster[:score] += 1 if depth_sd < 0.5
      cluster[:score_ratio] = cluster[:score] / cluster[:trees].count.to_f
    end

    clusters
      .reject{ |cluster| cluster[:items].count == 0 }
      .sort_by { |cluster| cluster[:score] }
  end
  module_function :grade_clusters

  # Try to find a single item in DOM tree
  def filter_item(tree, filters)
    filters.each do |key, filter|
      filter = filter[0] if filter.class == Array # TODO

      case filter 
      when String
        value = tree[:node].at(filter)
        if value
          tree[:item] ||= {}
          if value.text.empty?
            tree[:item][key] = value['src'] || value['href']
          else
            tree[:item][key] = value.text
          end
        end
      when Regexp
        match = filter.match(tree[:node].inner_html)
        if match && match.captures
          tree[:item] ||= {}
          tree[:item][key] = match.captures[0]
        end
      when Proc
        tree[:item][key] = filter.call(tree[:node])
      else
        raise ArgumentError, "#{filter} is not a valid filter type"
      end
    end
    tree
  end
  module_function :filter_item

  # Pick items from best cluster, or combine items from multiple clusters
  def items(clusters, filters)
    # Clusters need to have at least one item field per tree
    clusters
      .select!{|cluster| cluster[:score_ratio] >= 1.0 }

    return [] if clusters.to_a.count == 0

    # Find unique items, start with highest scoring clusters
    items = []

    # Pick two best groups
    clusters = clusters.sort_by {|cluster| cluster[:score_ratio]}.reverse[0, 2]
    clusters.each do |cluster|
      cluster[:items].each do |item|
        items << item
      end
    end
    items.uniq!

    # Keep best items of partial duplicates
    items.delete_if do |item|
      items.find_by_partial_hash(item).map(&:count).max > item.count
    end
    
    return items
  end
  module_function :items


  # Helper methods
  def self.simhash(data); data.simhash(hashbits: Jules::SIMHASH_BITLENGTH); end
end
