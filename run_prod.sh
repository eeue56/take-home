#!/bin/bash

# Be sure to change these in your app!
export S3_AUTH=
export S3_SECRET=
export S3_BUCKET=
export JOBS_CONTACT=
export AUTH_SECRET=

export BASE_URL=localhost:8080

# Uncomment these if you want to use the elm-bootstrapper branch
#pushd ./bootstrapper
#elm make Bootstrapper.elm --yes --output ../instance/server/bootstrap.js
#popd
#node instance/server/bootstrap.js


instance/server/run.sh
