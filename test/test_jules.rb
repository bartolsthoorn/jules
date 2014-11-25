require 'helper'

class TestJules < Test::Unit::TestCase
  def test_module_loaded
    assert_equal('constant', defined?(Jules))
  end
end

class Test1Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/test1.html'
    @doc = Nokogiri::HTML(open(@path))
  end

  def test_rearrange_trees
    trees = Jules.rearrange_trees(@doc)
    assert_equal(4, trees.count)
  end

  def test_cluster_trees
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)

    assert_equal(1, clusters.count)

    # Cluster contains the three articles
    assert_equal([0, 1, 2], clusters[0].map{|x| x[:index]}.sort)
  end

  def test_grade_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)

    filters = { title: 'h3' }
    clusters = Jules.grade_clusters(clusters, filters)

    assert_equal(1, clusters.count)

    cluster = clusters[0]
    assert_equal(3, cluster[:items].count)
    [1, 2, 3].each do |i|
      assert_equal("Article ##{i}", cluster[:items][i-1][:title])
    end
  end

  def test_collect
    items = Jules.collect(open(@path), { title: 'h3' })
    assert_equal(3, items.count)
  end
end

class Test2Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/test2.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = { title: 'h3', description: 'p' }
  end

  def test_rearrange_trees
    trees = Jules.rearrange_trees(@doc)
    assert_equal(7, trees.count)
  end

  def test_grade_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    assert_equal(3, clusters.count)

    clusters = Jules.grade_clusters(clusters, @filters)
    log_clusters(clusters, 'test2')

    assert_equal(3, clusters.count)
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(5, items.count)
  end
end

class Test3Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/test3.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = { n: /(\d+)\./, title: 'h3', description: 'p' }
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(4, items.count)

    first = items[0]
    assert_equal('First story', first[:title])
    assert_equal(1, first[:n].to_i)

    second = items[1]
    assert_equal('Second story', second[:title])
    assert_equal(2, second[:n].to_i)
  end
end

class Test4Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/test4.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = {
      title: 'h2',
      comments: [/(\d+) comments/, :optional],
      img: ['img', :optional]
    }
  end

  def test_rearrange_trees
    trees = Jules.rearrange_trees(@doc)
    assert_equal(3, trees.count)
  end

  def test_grade_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    assert_equal(1, clusters.count)

    clusters = Jules.grade_clusters(clusters, @filters)

    assert_equal(1, clusters.count)
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(3, items.count)
  end
end

=begin
class TestHNJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/hackernews.html'
    @filters = {
      title: 'td.title a',
      comments: /(\d+) comments/,
      points: /(\d+) points/
    }
    @doc = Nokogiri::HTML(open(@path))
  end

  def test_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    log_trees(clusters, 'hn')
    clusters = Jules.grade_clusters(clusters, @filters)
    log_clusters(clusters, 'hn')
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    pp items.to_a.map {|item| item }
    assert_equal(30, items.to_a.count)
  end
end

=begin
class TestProductHuntJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/producthunt.html'
    @filters = {
      title: 'a.title',
      description: 'span.description',
      votes: 'span.vote-count',
      user_image: 'img.user-image'
    }
    @doc = Nokogiri::HTML(open(@path))
  end

  def test_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    log_trees(clusters, 'producthunt')
    clusters = Jules.grade_clusters(clusters, @filters)
    log_clusters(clusters, 'producthunt')
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(23, items.count)
  end
end
=end

=begin
class TestEbayJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/ebay.html'
    @doc = Nokogiri::HTML(open(@path))
  end

  def test_collect
    filters = {
      title: 'h3.lvtitle a',
      price: 'li.lvprice',
      picture: 'div.lvpic img'
    }
    items = Jules.collect(open(@path), filters)
    #puts items.map{|item| item[:title] }
    assert_equal(8, items.count)
  end
end
=end

def log_clusters(clusters, name)
  Dir.mkdir('test/log') unless File.exists?('test/log')
  Dir.mkdir('test/log/'+name) unless File.exists?('test/log/'+name)
  clusters.each_with_index do |cluster, i|
    File.open("test/log/#{name}/#{i}.txt", 'w') do |f|
      f.write("Score #{cluster[:score]}\n")
      f.write("Depth SD #{cluster[:trees].map{|tree| tree[:depth]}.standard_deviation}\n")
      f.write("Trees #{cluster[:trees].count} ")
      f.write("(ratio #{cluster[:score]/cluster[:trees].count.to_f})\n")
      cluster[:trees].each do |tree|
        f.write("\nDepth: #{tree[:depth]} ========================== #{tree[:simhash]}\n")
        f.write(tree[:node].to_s)
        f.write("\n--------------------------\n")
        f.write(tree[:item].to_s + "\n")
      end
    end
  end
end
def log_trees(clusters, name)
  Dir.mkdir('test/log') unless File.exists?('test/log')
  Dir.mkdir('test/log/'+name) unless File.exists?('test/log/'+name)
  File.open("test/log/#{name}/trees.txt", 'w') do |f|
    clusters.each do |cluster|
      cluster[:trees].each do |tree|
        f.write({index: tree[:index], name: "#{tree[:node].name}.#{tree[:node]['class']}##{tree[:node]['id']}", hash: tree[:simhash]}.to_s)
        f.write("\n")
        #f.write(tree[:node].to_s)
        #f.write("\n")
      end
      f.write("---------------------\n")
    end
  end
end
