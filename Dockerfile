################################################################################
######### CONFIG ###############################################################
# expect actual username as argument, use "docker" as fallback.
ARG   BASE_IMAGE=nvidia/cudagl:10.0-runtime-ubuntu18.04
FROM ${BASE_IMAGE}
MAINTAINER Julien Morat "julien.morat@naverlabs.com"

ARG   USER_NAME
ARG   USER_UID=1000
ARG   PASSWD=1234
ARG   USER_HOME=/home/${USER_NAME}

################################################################################
######### base #################################################################
USER root
# Set correct environment variables.
ENV HOME /root
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
RUN   apt-get update && apt-get install -y sudo htop nano

######### SSH ##################################################################
RUN   apt-get install -y openssh-server
RUN   mkdir /var/run/sshd
RUN   echo 'root:$PASSWD' | chpasswd
RUN   sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN   sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
RUN   echo "X11Forwarding yes\nX11UseLocalhost no" >> /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN   sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#ENV   NOTVISIBLE "in users profile"
#RUN   echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

######### create non-root USER #################################################
## NOTE: docker build hangs/crashes when useradd with large UID
## NOTE: use --no-log-init as a workaround
## NOTE: https://github.com/moby/moby/issues/5419
RUN   useradd --no-log-init --home-dir ${USER_HOME} --create-home --uid ${USER_UID} --shell /bin/bash ${USER_NAME}
RUN   echo "${USER_NAME}:${PASSWD}" | chpasswd
RUN   usermod -aG sudo ${USER_NAME}
RUN   mkdir -p ${USER_HOME}/.ssh
COPY  ssh/id_rsa.pub ${USER_HOME}/.ssh/authorized_keys
RUN   chown -R $USER_NAME ${USER_HOME}/.ssh && \
      chmod 700 ${USER_HOME}/.ssh  && \
      chmod 600 ${USER_HOME}/.ssh/authorized_keys

######### prepare BOOT #########################################################
USER  root
COPY  start.bash /home/root/start.sh
ENTRYPOINT ["bash", "-l", "/home/root/start.sh"]
