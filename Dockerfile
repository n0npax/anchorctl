# Build Step
FROM golang:1.13 AS build

ENV GO111MODULE=on

# Prerequisites and vendoring
RUN mkdir -p $GOPATH/src/github.com/anchorageio/anchorctl
ADD . $GOPATH/src/github.com/anchorageio/anchorctl
WORKDIR $GOPATH/src/github.com/anchorageio/anchorctl

RUN go mod download

# Build
ARG build
ARG version
RUN CGO_ENABLED=0 go build -ldflags="-s -w -X main.Version=${version} -X main.Build=${build}" -o anchorctl
RUN cp anchorctl /

# Final Step
FROM alpine

# Base packages
RUN apk update
RUN apk upgrade
RUN apk add ca-certificates && update-ca-certificates
RUN rm -rf /var/cache/apk/*

# Copy binary from build step
COPY --from=build /anchorctl /home/

# Define the ENTRYPOINT
WORKDIR /home
CMD ["./anchorctl", "test",  "-i", "true", "-f", "/config/test.yaml", "-k", "kubetest"]
