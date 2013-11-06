# Rubytus

Resumable upload protocol implementation in Ruby

[![Gem Version](https://badge.fury.io/rb/rubytus.png)](http://badge.fury.io/rb/rubytus)
[![Build Status](https://travis-ci.org/picocandy/rubytus.png)](https://travis-ci.org/picocandy/rubytus)
[![Coverage Status](https://coveralls.io/repos/picocandy/rubytus/badge.png?branch=master)](https://coveralls.io/r/picocandy/rubytus?branch=master)
[![Dependency Status](https://gemnasium.com/picocandy/rubytus.png)](https://gemnasium.com/picocandy/rubytus)
[![Codeship Status for picocandy/rubytus](https://www.codeship.io/projects/752c6230-28d4-0131-3d51-0a1cd65a540f/status?branch=master)](https://www.codeship.io/projects/9065)

## Installation

```bash
$ gem install rubytus
```

## Usage

```
$ rubytusd --help
Usage: <server> [options]

Server options:
    -e, --environment NAME           Set the execution environment (default: development)
    -a, --address HOST               Bind to HOST address (default: 0.0.0.0)
    -p, --port PORT                  Use PORT (default: 9000)
    -S, --socket FILE                Bind to unix domain socket

Daemon options:
    -u, --user USER                  Run as specified user
    -c, --config FILE                Config file (default: ./config/<server>.rb)
    -d, --daemonize                  Run daemonized in the background (default: false)
    -l, --log FILE                   Log to file (default: off)
    -s, --stdout                     Log to stdout (default: false)
    -P, --pid FILE                   Pid file (default: off)

SSL options:
        --ssl                        Enables SSL (default: off)
        --ssl-key FILE               Path to private key
        --ssl-cert FILE              Path to certificate
        --ssl-verify                 Enables SSL certificate verification

Common options:
    -C, --console                    Start a console
    -v, --verbose                    Enable verbose logging (default: false)
    -h, --help                       Display help message

TUSD options:
    -f, --data-dir DATA_DIR          Directory to store uploaded and partial files (default: tus_data)
    -b, --base-path BASE_PATH        Url path used for handling uploads (default: /files/)
    -m, --max-size MAX_SIZE          How many bytes may be stored inside DATA_DIR (default: 1073741824)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
