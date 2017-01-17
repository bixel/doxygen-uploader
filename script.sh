#! /bin/sh

# cleanup ssh directory
rm -r $HOME/.ssh/*

# build the docs
rm -rf html/
doxygen Doxyfile

# either perform some ssh setup and upload via ssh or upload via curl
# and basic auth
if [ -z "$SSH_PRIVATE_KEY" ]; then
    echo "Using SSH upload"

    # save keys
    echo -e $SSH_PRIVATE_KEY > deploy_key
    # store the host ssh key
    ssh-keyscan -t rsa $DEPLOY_HOST 2> /dev/null | sort -u - $HOME/.ssh/known_hosts -o $HOME/.ssh/known_hosts
    # start ssh-agent and add the key
    eval "$(ssh-agent -s)"
    chmod 600 deploy_key
    ssh-add deploy_key
    scp -r html/* $SSH_USER@$DEPLOY_HOST:$DEPLOY_DIR
else
    echo "Using curl upload"
    # upload via curl
    curl -f -T html -u $CURL_USER:$CURL_PASSWORD $DEPLOY_URL
fi;
