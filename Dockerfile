FROM centos:7

USER root

ENV container=docker

RUN yum -y install wget

# Install Nifi

COPY ./files/nifi-1.5.0-bin.tar.gz  nifi-1.5.0-bin.tar.gz

#RUN unzip nifi-1.5.0-bin.zip
# RUN wget http://apache.mediamirrors.org/nifi/1.5.0/nifi-1.5.0-bin.zip

# extraction de fichiers nifi
RUN tar xvf nifi-1.5.0-bin.tar.gz

# installation de Java8
RUN yum -y install java-1.8.0-openjdk

# On rajoute java_home dans le bashrc
 RUN echo "export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk" >> ~/.bashrc
 RUN source ~/.bashrc

 USER nifi 
ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

USER root

#utilisé comme volume pour avoir hdfs-site et core-site
RUN mkdir -p /hadoop-conf

# Config Nifi
#RUN vim nifi.properties

RUN mkdir -p /opt/nifi

RUN mkdir -p /nifi_flow/in

COPY ./dev/flow.xml.gz /nifi-1.5.0/conf/flow.xml.gz

COPY ./script/entrypoint.sh /opt/nifi/entrypoint.sh
ENTRYPOINT ["bash", "-c", "/opt/nifi/entrypoint.sh" ]
