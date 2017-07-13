#!/usr/bin/env bash
# Sync git configuration upstream. This assumes that the git project has already been cloned.

set -x
# Top level directory where git projects will be cloned to.
GIT_ROOT=${GIT_ROOT:=/git}

GIT_AUTOSAVE_BRANCH=${GIT_AUTOSAVE_BRANCH:-autosave}

# Default time in seconds between commit / push.
INTERVAL=${GIT_PUSH_INTERVAL:-300}

if [ "${INTERVAL}"  = "0" ]; then
    echo "GIT_PUSH_INTERVAL set to 0 (disabled). Container will now sleep."
    echo "You can exec into this container and manually execute git commands"
    while true
    do
        sleep 100000
    done
fi


export GIT_SSH_COMMAND="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /etc/git-secret/ssh"

# We don't know the name of the git repo that was cloned, but there should only be a single config directory under the GIT_ROOT.
cd ${GIT_ROOT}/*


# This configures git to ignore file mode changes.
git config core.filemode false
git config user.email "auto-sync@forgerock.net"
git config user.name "Git Auto-sync user"

git branch ${GIT_AUTOSAVE_BRANCH}
git branch
git checkout ${GIT_AUTOSAVE_BRANCH}

while true 
do
    sleep "${INTERVAL}"
    t=`date`
    git add .
    git commit -a -m "autosave at $t"
    git push --set-upstream origin ${GIT_AUTOSAVE_BRANCH} -f
done