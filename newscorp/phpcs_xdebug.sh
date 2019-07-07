#!/usr/bin/env bash
php -d -dzend.enable_gc=0 /usr/local/bin/phpunit -c $@
