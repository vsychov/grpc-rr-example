FROM golang:alpine as grpcwebproxy-builder

RUN apk update && apk add git dep

WORKDIR /go

RUN GOPATH=/go; export GOPATH

RUN git clone https://github.com/improbable-eng/grpc-web.git $GOPATH/src/github.com/improbable-eng/grpc-web

WORKDIR /go/src/github.com/improbable-eng/grpc-web

RUN dep ensure -v

RUN go install ./go/grpcwebproxy

#result image
FROM alpine

WORKDIR /app

COPY --from=grpcwebproxy-builder /go/bin/grpcwebproxy .
