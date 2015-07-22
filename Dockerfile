FROM java:8
MAINTAINER Theo Meneau <tmeneau@xetus.com>

#
# Copy the war into the /data directory
# TODO: retrieve the war from an artifact repository instead
# and allow the specific version to retrieve to be configurable
#
ADD freeipa-pwd-portal-1.0-SNAPSHOT.war /opt/freeipa-pwd-portal/

#
# Perform the data directory initialization
#
ADD data_dirs.env /data_dirs.env
ADD templates/default_jaas.conf /default_jaas.conf
ADD templates/default_krb5.conf /default_krb5.conf
ADD templates/default_siteconfig.groovy /default_siteconfig.groovy
ADD templates/default_logback.groovy /default_logback.groovy

# Sync calls are due to https://github.com/docker/docker/issues/9547
ADD init.bash /init.bash
RUN chmod 755 /init.bash &&\
  sync && /init.bash &&\
  sync && rm /init.bash

#
# Add the bootstrap script
#
ADD run.bash /run.bash
RUN chmod 755 /run.bash

#
# Use the /data volume to contain all the persistent configurations
#
VOLUME ["/data"]

#
# Expose port 443
#
EXPOSE 443/tcp

ENTRYPOINT ["/run.bash"]