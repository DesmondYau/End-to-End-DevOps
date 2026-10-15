# 1st stage
FROM golang:1.22-alpine AS builder

# Set the worker directory
WORKDIR /usr/src/app

# Copy every files (including source code, go.mod, go.sum) in build context (directory where we run docker build) into current WORKDIR (/usr/src/app)
COPY . .

# Fetch project dependency listed in go.mod file
RUN go mod download

# Build go binary
RUN go build -o /go/bin/product-catalog .


# 2nd stage 
FROM alpine as release

WORKDIR /usr/src/app

# COPY ./prodcuts directory in build context into ./products in container (application reads json in this directory)
# Copy binary from 1st stage to current WORKDIR (usr/src/app)
COPY ./products ./products
COPY --from=builder /go/bin/product-catalog .

# Set environment variable used by application
ENV PRODUCT_CATALOG_PORT 8088

# Execute binary
ENTRYPOINT ["./product-catalog"]
