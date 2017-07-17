FROM alpine:latest

# Add command line argument variables used to cusomise the image at build-time.
ARG VARNISH_PORT=80
#ARG UTILITIES_BACKEND_IP=utilities
ARG UTILITIES_BACKEND_IP=127.0.0.1
ARG UTILITIES_BACKEND_PORT=3000
#ARG LIST_BACKEND_IP=list
ARG LIST_BACKEND_IP=127.0.0.2
ARG LIST_BACKEND_PORT=3000
#ARG THING_BACKEND_IP=thing
ARG THING_BACKEND_IP=127.0.0.3
ARG THING_BACKEND_PORT=3000

# Install system and application dependencies.
RUN apk update && \
    apk upgrade && \
    apk add varnish && \
    mkdir /scripts

ADD default.vcl /etc/varnish/default.vcl
ADD start.sh /scripts/start.sh

RUN chmod +x /scripts/start.sh && \
    chmod 777 /etc/varnish/default.vcl

ENV VARNISH_PORT $VARNISH_PORT
ENV UTILITIES_BACKEND_IP $UTILITIES_BACKEND_IP
ENV UTILITIES_BACKEND_PORT $UTILITIES_BACKEND_PORT
ENV LIST_BACKEND_IP $LIST_BACKEND_IP
ENV LIST_BACKEND_PORT $LIST_BACKEND_PORT
ENV THING_BACKEND_IP $THING_BACKEND_IP
ENV THING_BACKEND_PORT $THING_BACKEND_PORT

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