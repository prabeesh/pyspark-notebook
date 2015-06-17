FROM ubuntu:trusty

MAINTAINER Prabeesh K.

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" > /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
    
RUN apt-get -y update 

RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

RUN apt-get install -y curl

RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.4.0.tgz | tar -xz -C /usr/local/src/

RUN cd /usr/local/src/spark-1.4.0/ ; build/mvn -DskipTests clean package

ENV SPARK_HOME /usr/local/src/spark-1.4.0/
ENV PYTHONPATH $SPARK_HOME/python/:$PYTHONPATH

RUN apt-get install -y python \
    python-pip \
    python-zmq

RUN pip install py4j \
    ipython[notebook] \
    jsonschema \
    jinja2 \
    terminado \
    tornado

RUN ipython profile create pyspark

COPY pyspark-notebook.py /root/.ipython/profile_pyspark/startup/pyspark-notebook.py

VOLUME /notebook
WORKDIR /notebook

EXPOSE 8888

CMD ipython notebook --no-browser --profile=pyspark --ip=*
