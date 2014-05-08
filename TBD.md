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
