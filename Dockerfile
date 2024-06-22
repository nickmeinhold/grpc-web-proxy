FROM envoyproxy/envoy-alpine:v1.21-latest
COPY envoy.yaml /etc/envoy/envoy.yaml
RUN apk --no-cache add ca-certificates
ENTRYPOINT /usr/local/bin/envoy -c /etc/envoy/envoy.yaml -l trace