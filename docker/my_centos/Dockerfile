FROM docker.io/centos:7

RUN yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; \
    yum install -y bind-utils s3cmd; \
    yum clean all; \
    rm -rf /var/cache/yum


CMD ["/usr/sbin/init"]
