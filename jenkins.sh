#!/bin/bash
set -e

export RBENV_VERSION=2.2
bundle
bundle exec rake
bundle exec rake publish_gem
