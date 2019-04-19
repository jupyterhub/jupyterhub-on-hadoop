#!/bin/bash

set -ex

# Create user accounts
useradd -m alice
useradd -m bob
useradd -m carl
useradd -m jupyterhub

# Copy around default log4j.properties file
ln -s /etc/hadoop/conf.empty/log4j.properties /etc/hadoop/conf.temp/log4j.properties \
    && ln -s /etc/hadoop/conf.empty/log4j.properties /etc/hadoop/conf.kerberos/log4j.properties \

# Fix container-executor permissions
chmod 6050 /etc/hadoop/conf.kerberos/container-executor.cfg

# Create yarn directories with proper permissions
mkdir -p /var/tmp/hadoop-yarn/local /var/tmp/hadoop-yarn/logs \
    && chown -R yarn:yarn /var/tmp/hadoop-yarn/local /var/tmp/hadoop-yarn/logs

# Create secret key to authenticate web access
dd if=/dev/urandom bs=64 count=1 > /etc/hadoop/conf.kerberos/http-secret-file
chown hdfs:hadoop /etc/hadoop/conf.kerberos/http-secret-file
chmod 440 /etc/hadoop/conf.kerberos/http-secret-file

# Temporarily Configure HDFS to use non-kerberos credentials
alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.temp 50 \
    && alternatives --set hadoop-conf /etc/hadoop/conf.temp

# Format namenode
sudo -E -u hdfs bash -c "hdfs namenode -format -force"

# Format filesystem
# NOTE: Even though the worker and master will be different filesystems at
# *runtime*, the directories they write to are different so we can intitialize
# both in the same image. This is a bit of a hack, but makes startup quicker
# and easier.
# XXX: Add to hosts to resolve name temporarily
echo "127.0.0.1 master.example.com" >> /etc/hosts
sudo -E -u hdfs bash -c "hdfs namenode"&
sudo -E -u hdfs bash -c "hdfs datanode"&
sudo -E -u hdfs /root/init-hdfs.sh
killall java

# Configure to use kerberos config now
alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.kerberos 50 \
    && alternatives --set hadoop-conf /etc/hadoop/conf.kerberos

# Setup kerberos keytabs
create_keytabs() {
    HOST="$1.example.com"
    KEYTABS="/etc/hadoop/conf.kerberos/$1-keytabs"
    kadmin.local -q "addprinc -randkey hdfs/$HOST@EXAMPLE.COM" \
    && kadmin.local -q "addprinc -randkey mapred/$HOST@EXAMPLE.COM" \
    && kadmin.local -q "addprinc -randkey yarn/$HOST@EXAMPLE.COM" \
    && kadmin.local -q "addprinc -randkey HTTP/$HOST@EXAMPLE.COM" \
    && mkdir "$KEYTABS" \
    && kadmin.local -q "xst -norandkey -k $KEYTABS/hdfs.keytab hdfs/$HOST HTTP/$HOST" \
    && kadmin.local -q "xst -norandkey -k $KEYTABS/mapred.keytab mapred/$HOST HTTP/$HOST" \
    && kadmin.local -q "xst -norandkey -k $KEYTABS/yarn.keytab yarn/$HOST HTTP/$HOST" \
    && kadmin.local -q "xst -norandkey -k $KEYTABS/HTTP.keytab HTTP/$HOST" \
    && chown hdfs:hadoop $KEYTABS/hdfs.keytab \
    && chown mapred:hadoop $KEYTABS/mapred.keytab \
    && chown yarn:hadoop $KEYTABS/yarn.keytab \
    && chown hdfs:hadoop $KEYTABS/HTTP.keytab \
    && chmod 440 $KEYTABS/*.keytab
}

kdb5_util create -s -P adminpass \
&& create_keytabs master \
&& create_keytabs worker \
&& kadmin.local -q "addprinc -pw adminpass root/admin" \
&& kadmin.local -q "addprinc -pw testpass alice" \
&& kadmin.local -q "addprinc -pw testpass bob" \
&& kadmin.local -q "addprinc -pw testpass carl" \
&& kadmin.local -q "addprinc -randkey jupyterhub" \
&& kadmin.local -q "addprinc -randkey HTTP/edge.example.com@EXAMPLE.COM" \
&& kadmin.local -q "xst -norandkey -k /etc/jupyterhub/jupyterhub.keytab jupyterhub HTTP/edge.example.com" \
&& chown jupyterhub /etc/jupyterhub/jupyterhub.keytab \
&& chmod 400 /etc/jupyterhub/jupyterhub.keytab
