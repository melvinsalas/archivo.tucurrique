FROM jekyll/jekyll:pages

RUN apk add --no-cache build-base linux-headers
