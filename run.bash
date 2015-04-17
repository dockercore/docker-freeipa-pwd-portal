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
export STORE_AND_CERT_PASS=${STORE_AND_CERT_PASS:-changeit}
export CERT_ALIAS=${CERT_ALIAS:-freeipa-pwd-portal}

KEYSTORE_PATH="$JAVA_HOME/jre/lib/security/cacerts"
DATA_PATH=/data

function create_config {
  echo "Generating a $1 config file and backing it up to $3"
  mkdir -p "$(dirname "$3")"
  eval "echo \"`cat "$2"`\"" > "$3"
  rm "$2"
}

#
# Generate the configuration file templates from the passed environment
# variables
#
create_config "Krb5" /default_krb5.conf /etc/iris-template/krb5.conf
create_config "JAAS" /default_jaas.conf /etc/iris-template/jaas.conf
create_config "site" /default_siteconfig.groovy \
                     /etc/freeipa-pwd-portal-template/siteconfig.groovy
mv /default_logback.groovy /etc/freeipa-pwd-portal-template/logback.groovy

source /data_dirs.env
for datadir in "${DATA_DIRS[@]}"; do
  if [ ! -e "${DATA_PATH}/${datadir#/*}" ]
  then
    echo "Installing ${datadir}"
    mkdir -p ${DATA_PATH}/${datadir#/*}
    cp -pr ${datadir}-template/* ${DATA_PATH}/${datadir#/*}/
  fi
done

#
# Set the freeipa-pwd-portal siteconfig location as a permanent 
# environment variable
#
echo "com.xetus.freeipa.pwdportal.config=\
/etc/freeipa-pwd-portal" >> /etc/environment

#
#   KEYTAB - the keytab for authenticating using the
#   configured Kerberos Principal
#
if [[ -n "$KEYTAB" && -e "$KEYTAB" ]]; then
  echo "Installing the keytab file..."
  cp "$KEYTAB" /etc/iris/keytab
fi

#
#   FREEIPA_SSL_CERT - the FreeIPA instance's certificate
#
if [[ -n "$FREEIPA_SSL_CERT" && -e "$FREEIPA_SSL_CERT" ]]; then
  echo "Adding the FreeIPA instance's SSL certificate to the keystore..."
  keytool -import -trustcacerts -noprompt \
          -alias freeipa \
          -file "$FREEIPA_SSL_CERT" \
          -keystore "$KEYSTORE_PATH" \
          -storepass "$STORE_AND_CERT_PASS"
fi

#
# Create a java keystore and add the supplied certificate to the keystore. If 
# no certificate is supplied then generate a self-signed cert
#
#   FREEIPA_PWD_PORTAL_SSL_CERT - the certificate for the FreeIPA password 
#   portal
#
if [[ -n "$FREEIPA_PWD_PORTAL_SSL_CERT" && 
      -e "$FREEIPA_PWD_PORTAL_SSL_CERT" ]]; then
  echo "Adding the supplied password portal's SSL certificate to the keystore..."
  keytool -import -trustcacerts -noprompt \
          -alias "$CERT_ALIAS" \
          -file "$FREEIPA_PWD_PORTAL_SSL_CERT" \
          -keystore "$KEYSTORE_PATH" \
          -storepass "$STORE_AND_CERT_PASS"
else
  echo "No SSL certificate was supplied for the password portal; generating a \
temporary one now..."
  keytool -genkey -noprompt -trustcacerts \
          -keyalg RSA \
          -alias "$CERT_ALIAS" \
          -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown" \
          -keypass "$STORE_AND_CERT_PASS" \
          -keystore $KEYSTORE_PATH \
          -storepass "$STORE_AND_CERT_PASS"
fi

echo "Starting the Free IPA Password Portal..."
java -jar /opt/freeipa-pwd-portal/freeipa-pwd-portal-1.0-SNAPSHOT.war \
     -p 443 \
     -kf "$KEYSTORE_PATH" \
     -ka "$CERT_ALIAS" \
     -kp "$STORE_AND_CERT_PASS"