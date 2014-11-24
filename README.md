# jules
> Experimental

A fast way to write scrapers.
This is an ongoing project.

~~~ruby
require 'net/http'
require 'jules'
source = Net::HTTP.get('news.ycombinator.com', '/')

Jules::FILTERS = {
  title:    'td.title a',
  comments: [/(\d+) comments/, :optional],
  points:   /(\d+) points/
}

items = Jules.collect(source)
# [{title: '2 years with Angular', comments: 95, points: 245},
#  {title: 'PolarSSL is now a part of ARM', comments: 13, points: 48},
#  {title: 'My boys love 1986 computing', comments: 25, points: 105},
#  {title: 'Kill init by touching a bunch of files', comments: 66, points: 102},
#  ...
~~~

## How?

Jules uses the repitition of HTML structure. It rearranges the document based on similarity (Simhash) and subsequently grades the content using the user specified filters.

## Filters

Filters can be
- Strings (CSS selector / XPath query)
- Regexp
- Anonymous methods (`lambda`)

By default filters are required fields. If a field is optional, mark it with `['#example', :optional]`.

## Options

### Enabled HTML elements
By default, `div`, `tr` or `li` are enabled HTML elements for repitition. If a website wraps every item in `ul` and `div` elements, do this:

~~~ruby
Jules.collect(html, filters, ['ul', 'div'])
~~~
