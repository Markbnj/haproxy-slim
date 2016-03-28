# Implements an haproxy image on alpine linux. Includes everything
# but the configuration file.
#
# Installs rsyslog for remote logging.
#
FROM alpine
MAINTAINER Mark Betz <betz.mark@gmail.com>

RUN apk update &&\
 apk add bash &&\
 apk add rsyslog &&\
 apk add haproxy

ADD run_haproxy.sh /bin/
ADD rsyslog.conf /bin/
ADD 50-default.conf /bin/
ADD 49-remote.conf /bin/
ADD 49-remote-ls.conf /bin/

# command line arguments passed in the CMD at runtime
# will be passed through to iperf
ENTRYPOINT ["/bin/run_haproxy.sh"]
