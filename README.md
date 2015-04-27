# docker-freeipa-pwd-portal
A turnkey self service Free IPA password portal ready for most deployment situations. The key features are:

1. Externalized configuration through the /data volume, including auto-generation of basic Kerberos, JAAS, site, and log configuration files from the specified environment variables .
2. The ability to either change an expiring password (if the password is known) or to reset  password (if the password is not known).
2. Password reset request emails using the email address configured for the account in the Free IPA instance and with configurable request timeouts.
4. Optional ReCaptcha support.
5. Auto-installation of the Free IPA instance's certificate, the keystore containing the password portal's certificate (or generation of a self-signed certificate and keystore if none is provided), and the password portal's keytab.

|CAUTION|
|--------|
|The freeipa-pwd-portal war is not currently available in any public artifact repository. While the [image currently on DockerHub](https://registry.hub.docker.com/u/xetusoss/freeipa-pwd-portal/) **does** contain the freeipa-pwd-portal war, building this image from source requires manually building the war from the [freeipa-pwd-portal source](https://github.com/xetus-oss/freeipa-pwd-portal) and placing it in this project's root directory before building the image.|

# Quick Start

The command below will setup a freeipa-pwd-portal container with ReCaptcha disabled and a self-signed certificate:

```
docker run \
--name fpp \
-h freeipa-pwd-portal.example.com \
-p 443:443 \
-v /some/data/path:/data \
-e SMTP_HOST="smtp.example.com" \
-e SMTP_PORT="25" \
-e SMTP_FROM="freeipa-pwd-portal@example.com" \
-e FREEIPA_REALM="EXAMPLE.COM" \
-e FREEIPA_HOSTNAME="freeipa.example.com" \
-e FREEIPA_PWD_PORTAL_PRINCIPAL="host/freeipa-pwd-portal.example.com@EXAMPLE.COM" \
-e FREEIPA_SSL_CERT=/data/your_freeipa_instance_cert.cer \
-e KEYTAB=/data/your_pwd_portal_keytab \
xetusoss/freeipa-pwd-portal
```

# Available Configuration Parameters

* __SMTP_HOST__: The SMTP host to send notifications through. Default is "smtp.example.com".
* __SMTP_PORT__: The port to use on the SMTP host. Default is "25".
* __SMTP_FROM__: The address from which emails should be sent. Defaults to "freeipa-pwd-portal@examplecom".
* __SMTP_USER__: The username to use for authenticating against the SMTP_HOST. If neither this nor SMTP_PASS are specified, SMTP AUTH is not used. If SMTP_USER is not specified but smtpPass is, SMTP_FROM will be attempted as the user name for the SMTP AUTH.
* __SMTP_PASS__: The password for the SMTP_LOGIN address. If none is specified, will default to attempting to send the email without authentication.
* __FREEIPA_REALM__: The Kerberos realm that users will be authenticating against. Defaults to "EXAMPLE.COM".
* __FREEIPA_HOSTNAME__: The hostname for the Free IPA instance against which users will authenticate. Defaults to "freeipa.example.com".
* __FREEIPA_PWD_PORTAL_PRINCIPAL__: The Kerberos principal name the password portal should use for administrative authentication against the Free IPA instance. For details on creating the Free IPA host account, please see [the documentation for the freeipa-pwd-portal](https://github.com/xetus-oss/freeipa-pwd-portal).
* __RECAPTCHA_PRIVATE_KEY__: The recaptcha private key to use. ReCaptcha will be disabled for the site if none is supplied.
* __RECAPTCHA_PUBLIC_KEY__: The recaptcha public key to use. ReCaptcha will be disabled for the site if none is supplied.
* __DISABLE_RECAPTCHA__: Force disable ReCaptcha support. If either the RECAPTCHA_PRIVATE_KEY or _RECAPTCHA_PUBLIC_KEY options are ommitted, ReCaptcha support will be disabled regardless of the value for DISABLE_RECAPTCHA. Defaults to false.
* __PASSWORD_RESET_TIME_LIMIT__: The time limit before which the generated link in password reset emails will expire in seconds. Defaults to 900 seconds (15 minutes).
* __FREEIPA_PWD_PORTAL_KEYSTORE__: The java keystore containing the SSL certificate the password portal should use for serving HTTPS. If none is supplied, a self-signed SSL certificate will be generated in a newly generated keystore, and both will be used to serve HTTPS. This should be mounted somewhere in the `/data` volume mount prior to running the container.
* __FREEIPA_PWD_PORTAL_KEY_ALIAS__: The alias for the SSL certificate in the supplied keystore.
* __FREEIPA_PWD_PORTAL_KEY_PASS__: The password for both the supplied keystore and the contained SSL certificate (*FREEIPA_PWD_PORTAL*).
* __FREEIPA_SSL_CERT__: The SSL certificate for the FreeIPA instance with which the password portal will be communicating. This will be added to the container's JRE keystore. This should be placed somewhere in the /data volume mount prior to running the container.
* __KEYTAB__: The path within the Docker container to the valid password portal's Kerberos keytab. This should be placed somewhere in the /data volume mount prior to running the container referenced relative to the container, not the host. For details on creating the Free IPA host account, please see [the documentation for the GitHub account](https://github.com/xetus-oss/freeipa-pwd-portal).

Note that by default the web application will log to /var/log/freeipa-pwd-portal/application.log.

# Examples

(1) Enabling Recaptcha:

```
docker run \
--name fpp \
-h freeipa-pwd-portal.example.com \
-p 443:443 \
-v /some/data/path:/data \
-e SMTP_HOST="smtp.example.com" \
-e SMTP_PORT="25" \
-e SMTP_FROM="freeipa-pwd-portal@example.com" \
-e FREEIPA_REALM="EXAMPLE.COM" \
-e FREEIPA_HOSTNAME="freeipa.example.com" \
-e FREEIPA_PWD_PORTAL_PRINCIPAL="host/freeipa-pwd-portal.example.com@EXAMPLE.COM" \
-e RECAPTCHA_PRIVATE_KEY="your_private_key" \
-e RECAPTCHA_PUBLIC_KEY="your_public_key" \
-e FREEIPA_SSL_CERT=/data/your_freeipa_instance_cert.cer \
-e KEYTAB=/data/your_pwd_portal_keytab \
xetusoss/freeipa-pwd-portal
```

(2) Supplying a valid password portal keystore containing the valid SSL certificate:

```
docker run \
--name fpp \
-h freeipa-pwd-portal.example.com \
-p 443:443 \
-v /some/data/path:/data \
-e SMTP_HOST="smtp.example.com" \
-e SMTP_PORT="25" \
-e SMTP_FROM="freeipa-pwd-portal@example.com" \
-e FREEIPA_REALM="EXAMPLE.COM" \
-e FREEIPA_HOSTNAME="freeipa.example.com" \
-e FREEIPA_PWD_PORTAL_PRINCIPAL="host/freeipa-pwd-portal.example.com@EXAMPLE.COM" \
-e FREEIPA_SSL_CERT=/data/your_freeipa_instance_cert.cer \
-e FREEIPA_PWD_PORTAL_KEYSTORE=/data/private.keystore \
-e FREEIPA_PWD_PORTAL_KEY_PASS=somepass \
-e FREEIPA_PWD_PORTAL_KEY_ALIAS="freeipa-pwd-portal" \
-e KEYTAB=/data/your_pwd_portal_keytab \
xetusoss/freeipa-pwd-portal
```

# Authentication Stories

The freeipa-pwd-portal offers two main user stories:

1. Password Change (when the user still knows their password)

	In the case of a password change, the user is authenticated using their supplied password. At minimum the FREEIPA_REALM, FREEIPA_HOSTNAME, and FREEIPA_SSL_CERT must be provided for this to behave as expected.

2. Password Reset (when the user does not know their password or it has expired and needs to be changed administratively)

	In the case of a password reset, the password portal authenticates through it's FreeIPA HOST account (using an HTTP service for that host) using a Kerberos keytab, retrieves the user's information and generates a  password reset email with a secure link back to the portal that will allow the user to reset their password. The email is sent to the email address associated with the supplied uid in the Free IPA instance. 

	Once the user follows the generated link, the password portal uses its administrative access to change the password to a generated value and then immediately changes the password (as the user) to the supplied password. In addition to the above the SMTP_HOST, SMTP_PORT, SMTP_FROM_ADDRESS, FREEIPA_PWD_PORTAL_PRINCIPAL, and KEYTAB must additionally be specified for this to behave as expected. Please see [the documentation for the freeipa-pwd-portal](https://github.com/xetus-oss/freeipa-pwd-portal) for information on creating the HOST account, HTTP service and keytab.
