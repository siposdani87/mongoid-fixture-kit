#!/bin/sh
set -e

rubocop --format progress --format json --out coverage/rubocop-result.json
rake test
