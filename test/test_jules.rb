require 'helper'

class TestJules < Test::Unit::TestCase
  def test_module_loaded
    assert_equal('constant', defined?(Jules))
  end
end

class Test1Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/fake/1.html'
    @doc = Nokogiri::HTML(open(@path))
  end

  def test_rearrange_trees
    trees = Jules.rearrange_trees(@doc)
    assert_equal(3, trees.count)
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
    @path = 'test/html/fake/2.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = { title: 'h3', description: 'p' }
  end

  def test_rearrange_trees
    trees = Jules.rearrange_trees(@doc)
    assert_equal(6, trees.count)
  end

  def test_grade_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    assert_equal(2, clusters.count)

    clusters = Jules.grade_clusters(clusters, @filters)
    log_clusters(clusters, 'test2')

    assert_equal(2, clusters.count)
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(5, items.count)
  end
end

class Test3Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/fake/3.html'
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
    @path = 'test/html/fake/4.html'
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

class Test5Jules < Test::Unit::TestCase
  def setup
    @path = 'test/html/fake/5.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = {
      title: 'h2 a',
      comments: [/(\d+) reacties/, :optional],
      img: ['img', :optional]
    }
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(4, items.count)
  end
end

class TestSpeldJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/real/speld.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = {
      title: 'h2',
      comments: /(\d+) reacties/,
      img: 'img'
    }
  end

  def test_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    log_trees(clusters, 'speld')
    clusters = Jules.grade_clusters(clusters, @filters)
    log_clusters(clusters, 'speld')
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    assert_equal(10, items.count)

    # Check first four items
    data = [
      {title: 'Familie Hendriksen legt rotonde aan in woonkamer', comments: '43', img: 'http://cdn.speld.nl/wp-content/uploads/10409673_793181107369111_6156874726892003105_n.jpg'},
      {title: 'D66 wil dancemuziek op feesten testen', comments: '82', img: 'http://cdn.speld.nl/wp-content/uploads/CC-Wikipedia3.png'},
      {title: 'Slachthuizen vieren Slachtofferdag', comments: '61', img: 'http://cdn.speld.nl/wp-content/uploads/CC-Flickr-Annemee-Siersma-158x91.png'},
      {title: 'Wilde Pieten onterecht afgeschoten', comments: '86', img: 'http://cdn.speld.nl/wp-content/uploads/CC-Flickr-Redactie-Overbos-.png'}]

    data.each_with_index do |item, i|
      assert_equal(item, items[i])
    end

    # Check last item
    last = {title: 'Man neemt mooi weer mee naar goede vriend', comments: '52', img: 'http://cdn.speld.nl/wp-content/uploads/640px-Dutch_family_bbq.jpg'}
    assert_equal(last, items[-1])
  end
end

class TestTheOnionJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/real/theonion.html'
    @doc = Nokogiri::HTML(open(@path))
    @filters = {
      title: 'h1',
      pubdate: /(\d{2}\.\d{2}\.\d{2})/,
      img: 'img'
    }
  end

  def test_clusters
    trees = Jules.rearrange_trees(@doc)
    clusters = Jules.cluster_trees(trees)
    log_trees(clusters, 'onion')
    clusters = Jules.grade_clusters(clusters, @filters)
    log_clusters(clusters, 'onion')
  end

  def test_collect
    items = Jules.collect(open(@path), @filters)
    # TODO: Bob Skylar and Elizabeth Honing item is too different and doesn't show
    assert_equal(19, items.count)
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
=end

=begin
class TestProductHuntJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/real/producthunt.html'
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
    # TODO: ProductHunt doesn't work completely yet
    assert_equal(13, items.count)
  end
end
=end

=begin
class TestEbayJules < Test::Unit::TestCase
  def setup
    @path = 'test/html/real/ebay.html'
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
      cluster.each do |tree|
        f.write({index: tree[:index], name: "#{tree[:node].name}.#{tree[:node]['class']}##{tree[:node]['id']}", hash: tree[:simhash]}.to_s)
        f.write("\n")
        #f.write(tree[:node].to_s)
        #f.write("\n")
      end
      f.write("---------------------\n")
    end
  end
end
