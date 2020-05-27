FROM jenkins/jenkins:latest
USER root

# Install Maven
RUN mkdir /opt/maven \
  && cd /opt/maven \
  && wget http://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
  && tar -xf apache-maven-3.6.3-bin.tar.gz \
  && rm -rf apache-maven-3.6.3-bin.tar.gz

# Install Docker
RUN apt-get install \
  && apt-get install  apt-transport-https \
  && apt-get install ca-certificates \
  && apt-get install  gnupg-agent 
#  && apt-get install  software-properties-common  
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN chmod +x get-docker.sh
RUN sh get-docker.sh
RUN apt-get update \
  && apt-get install docker-ce docker-ce-cli containerd.io
RUN update-rc.d docker enable

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl 
RUN  chmod +x ./kubectl 
RUN mv ./kubectl /usr/local/bin/kubectl

ARG M2=/opt/maven/apache-maven-3.6.3/bin
ARG M2_HOME=/opt/maven/apache-maven-3.6.3
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV M2_HOME $M2_HOME
ENV M2 $M2
ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF
ENV PATH=$PATH:/opt/maven/apache-maven-3.6.3
ENV PATH=$PATH:/opt/maven/apache-maven-3.6.3/bin

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && usermod -aG docker jenkins
# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

