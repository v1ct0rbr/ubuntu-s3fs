FROM ubuntu:22.04 as envs
LABEL maintainer="Victor Queiroga <victorqueiroga.com>"

# Set arguments to be used throughout the image
#ARG OPERATOR_HOME="/home/op"
# Bitbucket-pipelines uses docker v18, which doesn't allow variables in COPY with --chown, so it has been statically set where needed.
# If the user is changed here, it also needs to be changed where COPY with --chown appears
#ARG OPERATOR_USER="op"
#ARG OPERATOR_UID="50000"

ARG MOUNT_PATH="/mnt/bucket"
ARG AWS_S3_ACCESS_KEY_ID
ARG AWS_S3_SECRET_ACCESS_KEY
ARG AWS_S3_BUCKET

# Attach Labels to the image to help identify the image in the future
LABEL com.victorqueirogabr.docker=true
LABEL com.victorqueirogabr.docker.distro="ubuntu"
LABEL com.victorqueirogabr.docker.module="s3fs-envs"
LABEL com.victorqueirogabr.docker.component="victorqueirogabr-s3fs-envs"
LABEL com.victorqueirogabr.docker.uid="${OPERATOR_UID}"

# Add environment variables based on arguments

#ENV BUCKET_NAME ${BUCKET_NAME}
#ENV S3_ENDPOINT ${S3_ENDPOINT}
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y kmod s3fs 

# Defina o Python 3 como o padrão
# RUN ln -s /usr/bin/python3 /usr/bin/python
RUN mkdir -p /mnt/bucket
VOLUME [ "/mnt/bucket" ]

# RUN mkdir -p ${OPERATOR_HOME}
# RUN echo 'user creation in progress...'
# RUN useradd -ms /bin/bash -d ${OPERATOR_HOME} --uid ${OPERATOR_UID} ${OPERATOR_USER}
# RUN chown -R ${OPERATOR_USER}:${OPERATOR_USER} ${OPERATOR_HOME}

RUN touch /root/docker-entrypoint.sh

RUN touch .s3fs-creds

#RUN echo "bucket ${AWS_S3_BUCKET}"


RUN echo '#!/bin/bash' > /root/docker-entrypoint.sh && \
    echo 'set -eo pipefail' >>  /root/docker-entrypoint.sh && \
    echo "echo ${AWS_S3_ACCESS_KEY_ID}:${AWS_S3_SECRET_ACCESS_KEY} > /root/.s3fs-creds" >> /root/docker-entrypoint.sh && \
    echo "chmod 400 /root/.s3fs-creds" >> /root/docker-entrypoint.sh && \
    echo "s3fs ${AWS_S3_BUCKET} /mnt/bucket -o _netdev,allow_other,nonempty,umask=000,passwd_file=/root/.s3fs-creds,use_cache=/tmp" >> /root/docker-entrypoint.sh && \
    echo "tail -f /dev/null" >> /root/docker-entrypoint.sh

RUN chmod +x /root/docker-entrypoint.sh

ENTRYPOINT [ "/root/docker-entrypoint.sh" ]




