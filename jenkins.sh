#!/bin/bash
set -e

bundle exec rake
bundle exec rake publish_gem
