#!/bin/bash
# Script to configure remote logging and start haproxy

set -euo pipefail
IFS=$'\n\t'

# environment variables read on startup:
#
# If RSYSLOG_REMOTE is false then haproxy will log to this path.
# LOG_PATH = PATH
#
# Use this facility as the rsyslog target
# RSYSLOG_FACILITY = facility
#
# Use the logstash output format
# RSYSLOG_LOGSTASH = [true || *false]
#
# Log to a remote server, at the specified IP and port
# RSYSLOG_REMOTE = [true || *false]
# RSYSLOG_REMOTE_IP = ip
# RSYSLOG_REMOTE_PORT = port
#

# initialize from environment
log_path=${LOG_PATH:-/var/log}
rsyslog_facility=${RSYSLOG_FACILITY:-local0}
rsyslog_logstash=${RSYSLOG_LOGSTASH:-false}
rsyslog_remote=${RSYSLOG_REMOTE:-false}
rsyslog_remote_ip=${RSYSLOG_REMOTE_IP:-}
rsyslog_remote_port=${RSYSLOG_REMOTE_PORT:-}

# configure and start rsyslogd
if [ ! -d "/etc/rsyslog.d" ]; then
    mkdir /etc/rsyslog.d
fi
mv /bin/rsyslog.conf /etc/
sed -i"" -e "s:##LOG_PATH##:${log_path}:g" -e "s:##FACILITY##:${rsyslog_facility}:g" /bin/50-default.conf
mv /bin/50-default.conf /etc/rsyslog.d/
if [ "${rsyslog_remote}" = "true" ]; then
    if [ "${rsyslog_logstash}" = "true" ]; then
        sed -i"" -e "s:##FACILITY##:${rsyslog_facility}:g" -e "s:##RSYSLOG_REMOTE_IP##:${rsyslog_remote_ip}:g" -e "s:##RSYSLOG_REMOTE_PORT##:${rsyslog_remote_port}:g" /bin/49-remote-ls.conf
        mv /bin/49-remote-ls.conf /etc/rsyslog.d/
        rm /bin/49-remote.conf
    else
        sed -i"" -e "s:##FACILITY##:${rsyslog_facility}:g" -e "s:##RSYSLOG_REMOTE_IP##:${rsyslog_remote_ip}:g" -e "s:##RSYSLOG_REMOTE_PORT##:${rsyslog_remote_port}:g" /bin/49-remote.conf
        mv /bin/49-remote.conf /etc/rsyslog.d/
        rm /bin/49-remote-ls.conf
    fi
else
    rm /bin/49-remote.conf
    rm /bin/49-remote-ls.conf
fi
/usr/sbin/rsyslogd

# start haproxy
exec haproxy -f /etc/haproxy/haproxy.cfg
