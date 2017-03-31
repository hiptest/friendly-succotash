Friendly succotash
==================

[![Build Status](https://travis-ci.org/hiptest/friendly-succotash.svg?branch=master)](https://travis-ci.org/hiptest/friendly-succotash)

Simple webhook server that updates a file by adding a line in file after a given placeholder and runs a command later on.

Install & run
-------------

Requires Ruby installed.

```shell
bundle
bundle exec rackup config.ru
```

Config file
-----------

Place a file named ``succotash.conf`` in the root folder. The content should look like this:

    file = pingers.txt
    placeholder = '# List of people who pingged me'
    command = 'less pingers.txt'

then, a simple ``curl http://localhost:9292/add_line?line=The new pinger`` will add the line "A pinger" in pingers.txt

Security
--------

You can specify a security_token entry in the config file. Then you should add a parameter 'token=XXXXXXX' in your cUrl request.

Naming
------

No freakin' idea, just followed Github proposition :)
