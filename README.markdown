# Woodhouse

[<img src="https://secure.travis-ci.org/mboeh/woodhouse.png?branch=master" alt="Build Status" />](http://travis-ci.org/mboeh/woodhouse)

An AMQP-based background worker system for Ruby designed to make managing heterogenous tasks relatively easy.

The use case for Woodhouse is for reliable and sane performance in situations where jobs on a single queue may vary significantly
in length. The goal is to permit large numbers of quick jobs to be serviced even when many slow jobs are in the queue. A secondary
goal is to provide a sane way for jobs on a given queue to be given special priority or dispatched to a server more suited to them.

Woodhouse 0.0.x is production-ready for Rails 2 and Ruby 1.8, while 0.1.x is in active development for Ruby 1.9.

## Usage

### Rails

Add

      gem 'woodhouse', github: 'mboeh/woodhouse', branch: 'next'

to your Gemfile.

Run
      
      % rails generate woodhouse

to create script/woodhouse and config/initializers/woodhouse.rb.

### Basic Usage

The simplest way to set up a worker class is to include Woodhouse::Worker and define public methods.

      class IsisWorker
        include Woodhouse::Worker

        def pam_gossip(job)
          puts "Pam gossips about #{job[:who]}."
        end

        def sterling_insult(job)
          puts "Sterling insults #{job[:who]}."
        end
      end

Jobs are dispatched asynchronously to a worker by adding @async\_@ to the method name:

      IsisWorker.async_pam_gossip :who => "Cyril"

Woodhouse jobs always take a hash of arguments. The worker receives a Woodhouse::Job, which acts like a hash
but also supplies additional functionality.

### Dispatchers

The dispatcher used for sending out jobs can be set in the Woodhouse config block:

      Woodhouse.configure do |woodhouse|
        woodhouse.dispatcher_type = :local # :local_pool | :amqp
      end
      
Calling the @async@ version of a job method sends it to the currently configured dispatcher. The default dispatcher
type is @:local@, which simply executes the job synchronously (although still passing it through middleware; see below).

If you want @girl\_friday@ style in-process threaded backgrounding, you can get that by selecting the @:local\_pool@
dispatcher.

Finally, if you want to run your jobs in a background process, you'll need to set up the @:amqp@ dispatcher. This will
use either the Hot Bunnies library (on JRuby) or the Bunny library (on all other Ruby engines). Bunny is suitable for
dispatch but can be a little bit CPU-hungry in the background process. Hot Bunnies works great for both. You don't have
to use the same Ruby version for your background process as for the dispatching application -- we use Woodhouse in production
with a JRuby background process and MRI frontend processes.

You'll also need to have RabbitMQ running. If it's running with the default (open) permissions on the local server, you don't
need to configure it at all. Otherwise, you'll have to set the server connection info. You have two options for this. On Rails,
you can create a config/woodhouse.yml file, formatted similar to config/database.yml:

      production:
        host: myrabbitmq.server.local
        vhost: /some-vhost

(The parameters accepted here are the same used for Bunny.connect; I promise to document them here soon.)

Otherwise, you can do it in the Woodhouse config block:

      Woodhouse.configure do |woodhouse|
        woodhouse.server_info = { :host => "myrabbitmq.server.local" }
      end

### Running The Background Process

All you have to do is run @script/woodhouse@. It'll load your Rails environment and start the server process. It responds to QUIT
and INT signals correctly; I'm working on seeing if I can get it to restart worker processes with HUP and to dump/load the current
layout with USR1/USR2.

@script/woodhouse@ logs job execution and results to @log/woodhouse.log@.

### Performance Errata

If you're using JRuby with a large application, I've found that the JVM's permanent generation can get exhausted. If you have
plenty of heap but still get GC overhead errors, try bumping up the PermGen by including this on the JRuby command line:

      -J-XX:MaxPermSize=128m

Performance will generally be better with the @--server@ flag:

      --server

A lot of the jobs I run tend to allocate and dispose a lot of memory very quickly, and Woodhouse will be a long-running process.
I've gotten good results from enabling aggressive heap tuning:

      -J-XX:+AggressiveHeap

## Features

* Configurable worker sets per server
* Configurable number of threads per worker
* Segmenting a single queue among multiple workers based on job characteristics (using AMQP header exchanges)
* Progress reporting on jobs
* New Relic background job reporting
* Job dispatch and execution middleware stacks

## Upcoming 

* Live reconfiguration of workers -- add or remove workers across one or more nodes without restarting
* Persistent configuration changes -- configuration changes saved to a data store and kept across deploys
* Watchdog/status workers on every node
* Web interface

## To Do

* Examples and guides
* More documentation
* Watchdog system

## Supported Versions

### woodhouse 0.1.x

* bunny 0.9.x, RabbitMQ 2.x or later
* ruby 1.9
* MRI, JRuby, Rubinius 2

### woodhouse 0.0.x

* ruby 1.8
* MRI, JRuby, Rubinius

### Acknowledgements

Woodhouse originated in a substantially modified version of the Workling background worker system, although all code has since
been replaced.

This library was developed for [CrowdCompass](http://crowdcompass.com) and was released as open source with their permission.
