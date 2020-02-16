# Stage 1 - the build react app
FROM --platform=$TARGETPLATFORM node:lts-alpine as build-deps
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building for $TARGETPLATFORM"

WORKDIR /usr/src/app
COPY client/package.json ./
ADD package.json ./
RUN npm install

COPY client/ ./
RUN npm run build

# Stage 2 - the production environment
FROM --platform=$TARGETPLATFORM node:lts-alpine

RUN apk add --no-cache tini
ENV NODE_ENV production
WORKDIR /usr/src/app
RUN chown -R node:node /usr/src/app/
EXPOSE 4654

COPY server/package.json ./
ADD package.json ./
RUN npm install --production

COPY --from=build-deps /usr/src/app/build /usr/src/app/public
COPY /server ./

USER node

ENTRYPOINT ["/sbin/tini", "--", "node", "."]
