# unobtainium-faraday

This gem provides a driver implementation for [unobtainium](https://github.com/jfinkhaeuser/unobtainium)
based on [faraday](https://github.com/lostisland/faraday).

[![Gem Version](https://badge.fury.io/rb/unobtainium-faraday.svg)](https://badge.fury.io/rb/unobtainium-faraday)
[![Build status](https://travis-ci.org/jfinkhaeuser/unobtainium-faraday.svg?branch=master)](https://travis-ci.org/jfinkhaeuser/unobtainium-faraday)
[![Code Climate](https://codeclimate.com/github/jfinkhaeuser/unobtainium-faraday/badges/gpa.svg)](https://codeclimate.com/github/jfinkhaeuser/unobtainium-faraday)
[![Test Coverage](https://codeclimate.com/github/jfinkhaeuser/unobtainium-faraday/badges/coverage.svg)](https://codeclimate.com/github/jfinkhaeuser/unobtainium-faraday/coverage)

To use it, require it after requiring unobtainium, then create the appropriate driver:

```ruby
require 'unobtainium'
require 'unobtainium-faraday'

include Unobtainium::World

drv = driver(:faraday)
```

The main purpose of this gem is to make API testing a little easier. To that
end, the driver (which is a faraday connection object) is initialized with some
middleware, in particular [faraday_json](https://github.com/spriteCloud/faraday_json)
to fix some encoding issues in the default middleware.

If you're coming from faraday, initializing the driver/connection is going to
feel a little different. Instead of the block-initialization favoured by faraday,
you pass an options hash:

```ruby
drv = driver(:faraday,
             uri: 'http://finkhaeuser.de',
             connection: {
               request: :json,
               response: [:logger, [:json, content_type: /\bjson$/ ]]
             })
```

Afterwards, using the driver is identical to faraday usage:

```ruby
res = drv.get '/'
puts res.body
```
