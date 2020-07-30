FROM --platform=$BUILDPLATFORM golang:1.14-alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG version="v0.4.0"


WORKDIR /opt

RUN apk add -U git
RUN git clone https://github.com/jimmidyson/configmap-reload.git
WORKDIR /opt/configmap-reload
RUN git checkout ${version}

RUN GOOS=$(echo $TARGETPLATFORM | cut -f1 -d/) && \
    GOARCH=$(echo $TARGETPLATFORM | cut -f2 -d/) && \
    GOARM=$(echo $TARGETPLATFORM | cut -f3 -d/ | sed "s/v//" ) && \
    CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go build ./



FROM gcr.io/distroless/static

COPY --from=builder /opt/configmap-reload/configmap-reload /bin/configmap-reload

EXPOSE      9100
USER        1234
ENTRYPOINT  [ "/bin/configmap-reload" ]


