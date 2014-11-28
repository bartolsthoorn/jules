# jules
> Experimental

A fast new way to write scrapers.
This is still an ongoing project.

~~~ruby
require 'open-uri'
require 'jules'
source = URI.parse('https://news.ycombinator.com').read

filters = {
  title:    'td.title a',
  comments: [/(\d+) comments/, :optional],
  points:   /(\d+) points/
}

items = Jules.collect(source, filters)
# [{title: '2 years with Angular', comments: '95', points: '245'},
#  {title: 'PolarSSL is now a part of ARM', comments: '13', points: '48'},
#  {title: 'My boys love 1986 computing', comments: '25', points: '105'},
#  {title: 'Kill init by touching a bunch of files', comments: '66', points: '102'},
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

### Examples
#### The Onion
~~~ruby
require 'open-uri'
require 'jules'
source = URI.parse('http://www.theonion.com/search/?q=why').read

filters = {
  title:   'h1',
  pubdate: /(\d{2}\.\d{2}\.\d{2})/,
  img:     'img'
}

items = Jules.collect(source, filters)
# [{title: 'Why Are We Leaving Facebook?', pubdate: '10.10.13', img: 'http://o.onionstatic.com/images/23/23823/16x9/350.jpg?0553'},
#  {title: 'Why Are We Filing For Disability?', pubdate: '01.24.14', img: 'http://o.onionstatic.com/images/25/25070/16x9/350.jpg?8738'},
#  {title: 'Why Are We Waiting To Have Children?', pubdate: '07.10.14', img: 'http://o.onionstatic.com/images/26/26746/16x9/350.jpg?7206'},
#  {title: 'Why Are We Postponing The Wedding?', pubdate: '04.25.13', img: '/images/21/21801/16x9/350.jpg?8189'},
#  {title: 'Why Are We Canceling Our Netflix Account?', pubdate: '01.09.14', img: 'http://o.onionstatic.com/images/24/24668/16x9/350.jpg?3803'},
#  {title: 'Why Aren't We Watching The Olympics?', pubdate: '02.20.14', img: 'http://o.onionstatic.com/images/25/25345/16x9/350.jpg?2178'},
#  ...
~~~
