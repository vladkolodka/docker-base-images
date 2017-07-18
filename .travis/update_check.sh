#!/bin/bash

# Handle errors
set -e
set -o pipefail

# Switch to Travis build directory (if available)
if [[ ! -z "${TRAVIS_BUILD_DIR}" ]]; then
    cd "${TRAVIS_BUILD_DIR}"
# Otherwise switch to root
else
    cd "${0%/*}/../"
fi

# Check if this is a pull request
if [[ ! -z ${TRAVIS_PULL_REQUEST+x} && "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    echo ""
    echo "NOTICE: Pull request detected, skipping update check.."
    echo ""
else
    # Environment variables exported at the end of the script
    UPDATE_UBUNTU_16_04=0
    UPDATE_UBUNTU_14_04=0
    UPDATE_ALPINE_3_5=0

    # Check each image for updates and set an environment
    # variable that's then used in the build script
    echo ""
    echo "Checking images for updates.."

    echo ""
    echo "  * Ubuntu 14.04"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --rm didstopia/base:ubuntu-14.04 bash -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_UBUNTU_14_04=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Ubuntu 16.04"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --rm didstopia/base:ubuntu-16.04 bash -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_UBUNTU_16_04=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Alpine 3.5"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --rm didstopia/base:alpine-3.5 /bin/ash -c "apk update > /dev/null && apk upgrade | grep \"Upgrading \"" | grep "Upgrading " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_ALPINE_3_5=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo -n "Exporting results as environment variables.. "
    export UPDATE_UBUNTU_14_04
    export UPDATE_UBUNTU_16_04
    export UPDATE_ALPINE_3_5
    echo -n "done"
    echo ""

    # Disable error handling (useful when running with "source")
    set +e
    set +o pipefail

    echo ""
    echo "Update check completed successfully."
    echo ""
fi
