FROM envoyproxy/envoy-alpine:v1.17.0  
COPY envoy.yaml /etc/envoy/envoy.yaml
EXPOSE 8080
RUN apk --no-cache add ca-certificates