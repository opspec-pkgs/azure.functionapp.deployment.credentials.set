#!/usr/bin/env sh
OK=0

# Login to Azure
#
# Required env variables:
#     $loginId
#     $loginSecret
#     $loginTenantId
#     $loginType
# On FAILURE: It output standar error
login()
{
    ### Login command
    loginCmd='az login --debug -u "$loginId" -p "$loginSecret"'

    # handle opts
    if [ "$loginTenantId" != " " ]; then
        loginCmd=$(printf "%s --tenant %s" "$loginCmd" "$loginTenantId")
    fi

    case "$loginType" in
        "user")
            echo "logging in as user"
            ;;
        "sp")
            echo "logging in as service principal"
            loginCmd=$(printf "%s --service-principal" "$loginCmd")
            ;;
    esac

    stdError=$(eval "$loginCmd" 2>&1)
    ERR=$?

    if [ $ERR != $OK ]; then
        (>&2 echo $stdError)
        return $ERR
    fi

    return $OK
}

# Sets the Azure subscription ID
#
# Required env variables:
#     $subscriptionId
setSubscription()
{
    echo "Setting default subscription"
    stdError=$(az account set --subscription "$subscriptionId" 2>&1)
    ERR=$?

    if [ $ERR != $OK ]; then
        (>&2 echo $stdError)
        return $ERR
    fi

    return $OK
}

# Sets the Azure functionapp deployment user credentials
#
# Required env variables:
#     $usernameCredential
#     $passwordCredential
setDeploymentUser()
{
    echo "Setting deployment credentials"
    stdError=$(az functionapp --debug deployment user set --user-name "$usernameCredential" --password "$passwordCredential" 2>&1)
    ERR=$?

    if [ $ERR != $OK ]; then
        (>&2 echo $stdError)
        return $ERR
    fi

    return $OK
}

login
ERR=$?

if [ $ERR = $OK ]; then
    setSubscription
    ERR=$?
    if [ $ERR = $OK ]; then
        setDeploymentUser
        ERR=$?
    fi
fi

exit $ERR
