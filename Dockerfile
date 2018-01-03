FROM alpine:latest

# Add command line argument variables used to cusomise the image at build-time.
ARG VARNISH_PORT=80

# Install system and application dependencies.
RUN apk update && \
    apk upgrade && \
    apk add varnish && \
    apk add python3 && \
    pip3 install boto3 && \
    mkdir /scripts && \
    mkdir /vcl

ADD vcl /vcl
ADD scripts /scripts

RUN chmod +x /scripts/start.sh && \
    ln -s /vcl/default.vcl /etc/varnish/default.vcl

ARG GIT_SHA=unknown
ARG GIT_TAG=unknown
LABEL git-sha=$GIT_SHA \
        git-tag=$GIT_TAG \
        rack-env=$RACK_ENV \
        maintainer=mattrayner1@gmail.com

# Expose port 80
EXPOSE 80

# Launch Varnish
CMD ["sh", "/scripts/start.sh"]