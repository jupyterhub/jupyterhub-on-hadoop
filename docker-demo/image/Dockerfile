FROM centos:centos7
MAINTAINER jcrist

# Install common utilities and kerberos
RUN yum install -y \
        sudo \
        bzip2 \
        java-1.8.0-openjdk \
        krb5-libs \
        krb5-server \
        krb5-workstation \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install supervisord
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py \
    && pip install supervisor \
    && rm get-pip.py

# The hadoop distro version to build for
ARG HADOOP_TESTING_VERSION=cdh5

# Install CDH
ADD cloudera-cdh*.repo /etc/yum.repos.d/
RUN if [[ "$HADOOP_TESTING_VERSION" == "cdh5" ]]; then \
        yum-config-manager --disable cloudera-cdh6 \
        && rpm --import https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/RPM-GPG-KEY-cloudera; \
    else \
        yum-config-manager --disable cloudera-cdh5 \
        && rpm --import https://archive.cloudera.com/cdh6/6.2.0/redhat7/yum/RPM-GPG-KEY-cloudera; \
    fi
RUN yum install -y \
        hadoop-yarn-resourcemanager \
        hadoop-hdfs-namenode \
        hadoop-yarn-nodemanager \
        hadoop-hdfs-datanode \
        hadoop-client \
        hadoop-libhdfs \
    && yum clean all \
    && rm -rf /var/cache/yum

# Copy over files
COPY ./files /

# Setup hadoop and kerberos
RUN /root/setup.sh

# Setup jupyterhub
RUN /root/setup-jupyterhub.sh

ENV HADOOP_TESTING_VERSION=$HADOOP_TESTING_VERSION
ENV LIBHDFS3_CONF /etc/hadoop/conf/hdfs-site.xml
ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV HADOOP_HOME /usr/lib/hadoop
ENV HADOOP_COMMON_HOME /usr/lib/hadoop
ENV HADOOP_YARN_HOME /usr/lib/hadoop-yarn
ENV HADOOP_HDFS_HOME /usr/lib/hadoop-hdfs
