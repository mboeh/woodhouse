# Woodhouse

[<img src="https://secure.travis-ci.org/mboeh/woodhouse.png?branch=master" alt="Build Status" />](http://travis-ci.org/mboeh/woodhouse)

An AMQP-based background worker system for Ruby designed to make managing heterogenous tasks relatively easy.

The use case for Woodhouse is for reliable and sane performance in situations where jobs on a single queue may vary significantly
in length. The goal is to permit large numbers of quick jobs to be serviced even when many slow jobs are in the queue. A secondary
goal is to provide a sane way for jobs on a given queue to be given special priority or dispatched to a server more suited to them.

Woodhouse 0.0.x is production-ready for Rails 2 and Ruby 1.8, while 0.1.x is in active development for Ruby 1.9.

Please look at the [wiki](https://github.com/mboeh/woodhouse/wiki) for documentation.

## Features

* Configurable worker sets per server
* Configurable number of threads per worker
* Segmenting a single queue among multiple workers based on job characteristics (using AMQP header exchanges)
* Extension system
* Progress reporting on jobs with the `progress` extension
* New Relic background job reporting with the `new_relic` extension
* Live status reporting with the `status` extension
* Job dispatch and execution middleware stacks

## Upcoming 

* Live reconfiguration of workers -- add or remove workers across one or more nodes without restarting
* Persistent configuration changes -- configuration changes saved to a data store and kept across deploys
* Web interface

## Acknowledgements

Woodhouse originated in a substantially modified version of the Workling background worker system, although all code has since
been replaced.

This library was developed for [CrowdCompass](http://crowdcompass.com) and was released as open source with their permission.
