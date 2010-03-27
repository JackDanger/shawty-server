# Shawty


The Shawty gem is the simplest and fastest Ruby url-shortening app. Run your own server that works like [tinyurl.com](http://tinyurl.com) or [is.gd](http://is.gd).


## Instant installation and deploy

* Clone this: `git clone git://github.com/JackDanger/shawty-server.git`
* Signup for an account at Heroku ([better details here](http://github.com/sinatra/heroku-sinatra-app))
* don't even bother configuring it
* push it to Heroku.com: `git push heroku master`
* Revel.


## Why?

If you run any application with published content it's helpful to have shorter links to that content.

Consider that your Rails app might offer pages like the following:

    http://myapp.com/accounts/megacorp/invoices?single_access_token=5ASD32ADf89JKASF2346

Imagine trying to fit that in a text message. Instead, how about:

    http://url.myapp.com/a7D

## Is it so easy a child can use it?

Yes. See the [shawty-client](http://github.com/JackDanger/shawty-client) gem for details:

    Shawty.new(
        "http://url.myapp.com/"
      ).shrink(
        "http://myapp.com/accounts/megacorp/invoices?single_access_token=5ASD32ADf89JKASF2346"
      )
    # => http://url.myapp.com/a7D
    ## Saved on your url.myapp.com shawty server and usable immediately

Way groovy.


Patches welcome, forks celebrated.

Copyright (c) 2009 [Jack Danger Canty](http://jåck.com). See LICENSE for details.