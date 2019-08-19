FROM registry.access.redhat.com/ubi8/s2i-core

EXPOSE 8080

ARG WASI_VERSION

ENV WASI_VERSION=${WASI_VERSION} \
    DEBUG_PORT=5858 \
    SUMMARY="Platform for building and running WASI ${WASI_VERSION} applications" \
    DESCRIPTION="TBD"

LABEL io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="WASI $WASI_VERSION" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,wasi" \
      com.redhat.deployments-dir="/opt/app-root/src" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858" \
      maintainer="Daniel Bevenius <daniel.bevenius@gmail.com>" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      version="$WASI_VERSION" \
      name="nodeshift/ubi8-s2i-wasi" \
      usage="s2i build . nodeshift/ubi8-s2i-wasi myapp"

COPY ./s2i/ $STI_SCRIPTS_PATH
COPY ./contrib/ /opt/app-root
COPY ./binaries/wasmtime /usr/bin

#RUN yum remove -y node npm

USER 1001


# Set the default CMD to print the usage
CMD ${STI_SCRIPTS_PATH}/usage
