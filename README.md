# haproxy-slim

haproxy-slim is just an experiment in creating a slim haproxy image which
consists of a base image on alpine linux, containing haproxy as well as
rsyslog, and a final image that contains just the config file. More on
why below.

[docker pull markbnj/haproxy:1.6.2](https://hub.docker.com/r/markbnj/haproxy/)

### Why?

Having deployed haproxy several times in containerized environments on
both AWS and Google Cloud, I've been giving some thought to the way it
handles configuration, which comes into play in service discovery contexts
where you want to update the routing to reflect the addition or removal
of some service.

Typically the approach is some variation of: update the config and then
get haproxy to do a fast reload by forking itself. However this violates
the principle of keeping containers immutable.

In an orchestrated environment like kubernetes, for example, what you would
want is something like this:

  1) Push updated config to a repo
  2) Build system kicks off and builds an image with the new config
  3) Do a graceful update

There's a lot in (3) but I don't want to go down that hole here. The main
thing is that you're rebuilding your image and redeploying it. The new image
gets the new config, and you can use various techniques to start moving
traffic to it.

In this scenario the time to build, push, and subsequently pull the image
will be the main factor in how long it takes to update haproxy and get
the new rules into effect.

So these two images are the beginning of some experiments around that. The
base image has haproxy 1.6.2 (currently the alpine package version), and
rsyslog. The final image depends on the base and just adds the config file.

This should allow those base image layers to get cached and make pushes/pulls
where only the config changes quite fast. The whole image is at this point
only 12 MB.