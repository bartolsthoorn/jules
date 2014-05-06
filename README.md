**Hi!** - Don't use this gem _yet_, it's still very much being developed.

# Jules
A data mining scraper with a high level of abstraction. It's capable of finding _lists_, _menus_, _titles_ and _contact data_.

Jules uses semantics, patterns and NLP to find data, so you don't have to specify exactly where it is. You'll no longer have to make different scrapers for every new website you want to scrape.

~~~ruby
gem 'jules'
~~~

## Examples
The following examples show you how to use Jules.
### Lists
~~~ruby
html = File.open('web-page.html', 'rb') { |f| f.read }
j = Jules::HTML(html)
lists = j.lists
~~~

The following example gets lists only when they contain certain data types.
~~~ruby
j = Jules::HTML(html)
lists = j.lists(
  required: [:date, :price],
  optional: [:download_link]
)
~~~

### Jules Abstractions
- Lists
- Titles
- Menus

### Jules Data Types
- Date *:date*
- Price *:price*
- Filesize *:filesize*
- Download url *:download_url*
- Telephone number *:telephone_number*
