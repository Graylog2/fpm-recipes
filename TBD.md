To Be Discussed
===============

## Package Dependencies

Do we want the packages depend on MongoDB and Elasticsearch?

### Pro

* Installing the graylog2-server package is all that's needed to get started.

### Con

* MongoDB and Elasticsearch might run on different machines so requiring both
  on every graylog2-server instance is not required and probably not wanted.
* There might be different names for different versions on the same OS.
  i.e. MongoDB on Ubuntu:

  * mongodb -- ships with Ubuntu
  * mongodb-10gen -- 2.4.x with upstream repos
  * mongodb-org -- 2.6.x with upstream repos

  While it's possible to specify OR dependencies, this will be a pain to
  maintain.
* Depending on packages that are pulled from another 3rd party (Elasticsearch)
  will cause pain for users when repositories are not setup correctly.
  Especially when hard version dependencies are involved like
  `elasticsearch (=0.90.10)`.

### Ideas

* Offer meta-packages that depend on the graylog2 components and the 3rd party
  stuff. Like a graylog2-server-complete which depends on MongoDB and Elasticsearch.
  This will help users that do not use any kind of config management.
* Offer Puppet / Chef modules with separate profiles and handle dependencies between MongoDB, Elasticsearch and   Graylog2 there

## General Ideas

### Use dialogs for meta packages

If we go for meta packages, adding dialogs which asks some questions for
the initial configuration might be nice.

* Ask for ES cluster name, MongoDB address, etc.
* deb -- http://www.fifi.org/doc/debconf-doc/tutorial.html
* rpm -- ?
