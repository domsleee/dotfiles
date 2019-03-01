#!/bin/bash

backup() {
  echo "*** functions ***"
  typeset -f

  echo "*** variables ***"
  printenv

  echo "*** aliases ***"
  alias
}
