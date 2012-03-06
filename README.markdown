# Ganymede

An AMQP-based background worker system for Ruby 1.8 and 1.9 designed to make managing heterogenous tasks relatively easy.

The use case for Ganymede is for reliable and sane performance in situations where jobs on a single queue may vary significantly
in length. The goal is to permit large numbers of quick jobs to be serviced even when many slow jobs are in the queue. A secondary
goal is to provide a sane way for jobs on a given queue to be given special priority or dispatched to a server more suited to them.

## Features (planned)

* Configurable worker sets per server
* Configurable number of threads per worker
* Segmenting a single queue among multiple workers based on job characteristics (using AMQP header exchanges)
* Live reconfiguration of workers -- add or remove workers across one or more nodes without restarting
