#!/bin/bash
set -e

export RUBY_VERSION=2.2
bundle exec rake
bundle exec rake publish_gem
