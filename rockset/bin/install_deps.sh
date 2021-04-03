#/bin/zsh
# Crash if something goes wrong
set -e

# If verbose is not set, drop all output to /dev/null
# https://stackoverflow.com/questions/65165875/redirect-output-to-dev-null-only-if-verbose-is-not-set
if [[ ${VERBOSE:-0} ]]; then
    exec 3>/dev/null
    exec 4>/dev/null
    PIP_COMMAND="pip3 -q"
else
    exec 3>&1
    exec 4>&2
    PIP_COMMAND="pip3"
fi


# Be simple, assume everything has been installed
cd $(dirname $0)
# We are in the bin directory
BASE_DIR=$(dirname $(pwd))
cd ${BASE_DIR?}


export REQUIREMENTS_TXT=${BASE_DIR}/dev_requirements.txt
export VENV_DIR=${BASE_DIR}/venv/

# Install packages
# Need to install aws globally
if ! pip3 freeze | grep awscli 1>/dev/null 2>/dev/null; then 
    echo "Installing global awscli to pick up the \`aws\` command"
    ${PIP_COMMAND?} install awscli
fi

# Configure AWS if needed.  
if [ -f ${HOME}/.aws/config ]; then
    echo "A previous aws configuration exists in ${HOME}/.aws/"
    echo "If this is out of date, please run \`aws configure\`"
else
    echo "No aws configuration exists in ${HOME}/.aws/"
    while true; do
        read -p "Do you wish to add this now?" yn
        case $yn in
            [Yy]* ) 
                aws configure 
                break;;
            [Nn]* ) 
                echo "Please run \`aws configure\` at a later date"
                break;;
            * ) echo "Please answer [y]es or [n]o.";;
        esac
    done
fi

echo "Installing brew dependencies"
if ! which eksctl 1>/dev/null 2>/dev/null; then
    brew tap weaveworks/tap >&3 2>&4
    brew install weaveworks/tap/eksctl >&3 2>&4
fi

if ! which kubectl 1>/dev/null 2>/dev/null; then
    brew install kubernetes-cli >&3 2>&4

fi

if ! which minikube 1>/dev/null 2>/dev/null; then
    brew install minikube >&3 2>&4
    if ! which minikube 1>/dev/null 2>/dev/null; then
        brew cask remove minikube
    fi
fi

echo "Creating a virtualenv and installing Python Packages"
python3 -m venv ${VENV_DIR?}
source ${VENV_DIR?}/bin/activate

${PIP_COMMAND?} install -U pip 
${PIP_COMMAND?} install --upgrade -r ${REQUIREMENTS_TXT?}
deactivate

echo "All dependencies have been installed"
echo "To use the development venv, run:"
echo ""
echo "    source ${VENV_DIR?}/bin/activate"
echo ""
