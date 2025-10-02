FROM golang:1.25.1-alpine AS build
ARG VERSION="dev"

WORKDIR /build

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build \
    -ldflags="-s -w -X main.version=${VERSION}" \
    -o /bin/github-mcp-server ./cmd/github-mcp-server

FROM gcr.io/distroless/base-debian12

LABEL io.modelcontextprotocol.server.name="io.github.github/github-mcp-server"

WORKDIR /server

COPY --from=build /bin/github-mcp-server .

ENTRYPOINT ["/server/github-mcp-server"]
CMD ["--help"]

