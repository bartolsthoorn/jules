require 'jules/version'
require 'nokogiri'
require 'simhash'

require 'nokogiri/sugar'
require 'simhash/sugar'

module Jules
  SIMILARITY_THRESHOLD = 0.6
  SIMHASH_BITLENGTH = 64 # 128
  ELEMENTS = ['div', 'li', 'tr']

  def self.collect(html, filters, elements=Jules::ELEMENTS)
    document =  Nokogiri::HTML(html)
    trees =     Jules.rearrange_trees(document, elements)
    clusters =  Jules.cluster_trees(trees)
    clusters =  Jules.grade_clusters(clusters, filters)
    Jules.items(clusters)
  end

  # Rearranges DOM trees with Simhash
  def rearrange_trees(document, elements=Jules::ELEMENTS)
    trees = []
    xpath = elements.map{ |x| '//' + x }.join('|')
    document.search(xpath).each do |tree|
      structure = Nokogiri::XML.remove_markup_outline(tree.inner_html).strip
      if structure.empty?
        tree.remove # This HTML tree does not contain any structure
        next
      end

      trees << {
        node: tree,
        simhash: structure.simhash(hashbits: Jules::SIMHASH_BITLENGTH),
        index: tree.xpath('count(preceding-sibling::*)').to_i
      }
    end
    trees.sort_by { |tree| tree[:simhash] }
  end
  module_function :rearrange_trees

  # Cluster trees based on similarity
  def cluster_trees(trees)
    clusters, cluster = [], []

    trees.each_with_index do |tree, i|
      cluster << tree
      break if trees[i+1].nil? # Break out
      similarity = Simhash.similarity(tree[:simhash], trees[i+1][:simhash])
      if similarity < Jules::SIMILARITY_THRESHOLD
        clusters << {trees: cluster}
        cluster = []
      end
    end
    clusters << {trees: cluster} if cluster.count > 0
    # Reject clusters that only contain 1 item
    clusters.reject { |c| c[:trees].count < 2 }
  end
  module_function :cluster_trees

  # Grade clusters
  def grade_clusters(clusters, filters)
    clusters.each do |cluster|
      cluster[:score] = 0
      cluster[:trees].each do |tree|
        tree = filter_item(tree, filters)

        # TODO: only count optional filters
        #if filters.count == tree[:item].to_h.count
          cluster[:score] += tree[:item].to_h.count
        #else
          # Incomplete item, destroy
        #  tree[:item] = nil
        #end
      end
      cluster[:items] = cluster[:trees]
        .sort_by { |tree| tree[:index] }
        .map { |tree| tree[:item] }
        .reject { |x| x.nil? }
    end
    clusters
      .reject{ |cluster| cluster[:score] == 0 }
      .sort_by { |cluster| cluster[:score] }
  end
  module_function :grade_clusters

  # Try to find a single item in DOM tree
  def filter_item(tree, filters)
    filters.each do |key, filter|
      if filter.class == String
        value = tree[:node].at(filter)
        if value
          tree[:item] ||= {}
          if value.text.empty?
            tree[:item][key] = value['src'] || value['href']
          else
            tree[:item][key] = value.text
          end
        end
      end
      if filter.class == Regexp
        match = filter.match(tree[:node].inner_html)
        if match && match.captures
          tree[:item] ||= {}
          tree[:item][key] = match.captures[0]
        end
      end
      if filter.class == Proc
        tree[:item][key] = filter.call(tree[:node])
      end
    end
    tree
  end
  module_function :filter_item

  # Pick items from best cluster, or combine items from multiple clusters
  def items(clusters)
    # Clusters need to have at least one item field per tree
    clusters
      .select!{|cluster| cluster[:score]/cluster[:trees].count.to_f >= 1.0 }

    if clusters.to_a.count == 0
      return []
    elsif clusters.count == 1
      return clusters[-1][:items]
    elsif clusters.count == 2
      # HACK
      # Interleave items spread out over two clusters
      # Use indices of items to test for interleavement
      c1_indices = clusters[0][:trees].map{|tree| tree[:index]}.sort
      c2_indices = clusters[1][:trees].map{|tree| tree[:index]}.sort
      puts ''
      puts c1_indices.zip(c2_indices).to_s
      
      interleaved = c1_indices.zip(c2_indices)
        .each_cons(2)
        .all?{|i,j| i.first <= i.last && i.last <= j.first && j.first <= j.last}
      if interleaved
        # Start with group with lowest index first
        sorted_clusters = clusters
          .sort_by{ |c| c[:trees].map{|tree| tree[:index]}.sort[0] }
        sorted_clusters[0][:trees].each do |tree|
          i = tree[:index]
          tree[:item].merge!(
            sorted_clusters[1][:trees].select{|tree| tree[:index] == i+1 }[0][:item]
          )
        end
        return sorted_clusters[0][:trees].map{|tree| tree[:item]}
      else
        return clusters[-1][:items]
      end
    end
  end
  module_function :items
end
