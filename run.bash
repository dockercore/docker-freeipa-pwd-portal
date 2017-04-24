#!/bin/bash
#
# freeipa-pwd-portal container bootstrap. See the readme for details
#

#
# Define some necessary global defaults
#
export FREEIPA_REALM=${FREEIPA_REALM:-EXAMPLE.COM}
export FREEIPA_REALM_LOWERCASE=${FREEIPA_REALM,,}
export FREEIPA_HOSTNAME=${FREEIPA_HOSTNAME:-freeipa.example.com}

export FREEIPA_PWD_PORTAL_KEYSTORE=${FREEIPA_PWD_PORTAL_KEYSTORE:-/data/freeipa-pwd-portal.keystore}
export FREEIPA_PWD_PORTAL_KEY_PASS=${FREEIPA_PWD_PORTAL_KEY_PASS:-changeit}
export FREEIPA_PWD_PORTAL_KEY_ALIAS=${FREEIPA_PWD_PORTAL_KEY_ALIAS:-freeipa-pwd-portal}

JRE_KEYSTORE_PATH="/etc/ssl/certs/java/cacerts"
JRE_KEYSTORE_PASS="changeit"
DATA_PATH=/data

function create_config {
  echo "Generating $2"
  mkdir -p "data/$(dirname "$2")"
  eval "echo \"`cat "$1"`\"" > "$2"
  rm "$1"
}

#
# Generate the configuration file templates from the passed environment
# variables
#
create_config /default_krb5.conf /etc/iris/krb5.conf
create_config /default_jaas.conf /etc/iris/jaas.conf
create_config /default_siteconfig.groovy \
                     /etc/freeipa-pwd-portal/siteconfig.groovy

[[ -e /etc/freeipa-pwd-portal/logback.groovy ]] ||
  mv /default_logback.groovy /etc/freeipa-pwd-portal/logback.groovy


#
# Set the freeipa-pwd-portal siteconfig location as a permanent 
# environment variable
#
[[ -n "$(cat /etc/environment | grep "com.xetus.freeipa.pwdportal.config")" ]] ||
  echo "com.xetus.freeipa.pwdportal.config=\
/etc/freeipa-pwd-portal" >> /etc/environment

#
#   FREEIPA_SSL_CERT - the FreeIPA instance's certificate
#
if [[ -n "$FREEIPA_SSL_CERT" && -e "$FREEIPA_SSL_CERT" ]]; then
  echo "Adding the FreeIPA instance's SSL certificate to the JRE keystore..."
  keytool -import -trustcacerts -noprompt \
          -alias freeipa \
          -file "$FREEIPA_SSL_CERT" \
          -keystore "$JRE_KEYSTORE_PATH" \
          -storepass "$JRE_KEYSTORE_PASS"
fi

#
# If no keystore is supplied containing the freeipa-pwd-portal private and public
# keys then generate a self-signed cert
#
#   FREEIPA_PWD_PORTAL_KEYSTORE - the keystore containing the freeipa-pwd-portal
# cert
#   FREEIPA_PWD_PORTAL_CERT_ALIAS - the alias for the certificate
#   FREEIPA_PWD_PORTAL_KEY_PASS - the password to use for the keystore and certificate
#
if [[ ! -n "$FREEIPA_PWD_PORTAL_KEYSTORE" ||
      ! -e "$FREEIPA_PWD_PORTAL_KEYSTORE" ]]; then
  echo "No keystore was supplied with the password portal's certificate; \
generating a temporary one now..."
  keytool -genkey -noprompt -trustcacerts \
          -keyalg RSA \
          -alias "$FREEIPA_PWD_PORTAL_KEY_ALIAS" \
          -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown" \
          -keypass "$FREEIPA_PWD_PORTAL_KEY_PASS" \
          -keystore "$FREEIPA_PWD_PORTAL_KEYSTORE" \
          -storepass "$FREEIPA_PWD_PORTAL_KEY_PASS"
fi

echo "Starting the Free IPA Password Portal..."
java -jar /opt/freeipa-pwd-portal/freeipa-pwd-portal.war \
     -p 443 \
     -kf "$FREEIPA_PWD_PORTAL_KEYSTORE" \
     -ka "$FREEIPA_PWD_PORTAL_KEY_ALIAS" \
     -kp "$FREEIPA_PWD_PORTAL_KEY_PASS"