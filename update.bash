#!/bin/bash

set -euo pipefail

remote_name=upstream
git fetch ${remote_name}
for branch in master devel; do
    git checkout ${branch}
    git rebase ${remote_name}/${branch}
    git push
done
