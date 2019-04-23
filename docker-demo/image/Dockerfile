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

# Install CDH
# Note: We force remove a couple unnecessary packages to shrink the docker
# image slightly
ADD cloudera-cdh6.repo /etc/yum.repos.d/
RUN rpm --import https://archive.cloudera.com/cdh6/6.2.0/redhat7/yum/RPM-GPG-KEY-cloudera \
    && yum install -y \
        hadoop-yarn-resourcemanager \
        hadoop-hdfs-namenode \
        hadoop-yarn-nodemanager \
        hadoop-hdfs-datanode \
        hadoop-client \
        hadoop-libhdfs \
        spark-core \
        spark-python \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /usr/lib/kite \
    && rm -rf /usr/lib/hive \
    && rm -rf /usr/lib/solr \
    && rm -rf /usr/lib/sentry \
    && rm -rf /usr/lib/flume-ng

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
ENV SPARK_HOME /usr/lib/spark
ENV JAVA_HOME /usr/lib/jvm/jre
