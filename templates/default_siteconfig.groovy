
/*
 * The ReCaptcha public and private keys. If one is missing, the password
 * portal should automatically flag ReCaptcha as disabled for the site.
 * Alternatively, you can force disable ReCaptcha by changing the
 * disableRecaptcha flag to true.
 *
 * See the following link to get a public and private key from Google:
 *  https://www.google.com/recaptcha/admin#list
 *
 */ 
recaptchaPrivateKey = "\"${RECAPTCHA_PRIVATE_KEY}\""
recaptchaPublicKey = "\"${RECAPTCHA_PUBLIC_KEY}\""
disableRecaptcha = ${DISABLE_RECAPTCHA:-false}

if (recaptchaPrivateKey == \"\" || recaptchaPublicKey == \"\") {
  disableRecaptcha = true
}

/*
 * The amount of time that a password reset link is valid. Default
 * is 15 minutes
 */
passwordResetRequestTimeLimit = ${PASSWORD_RESET_TIME_LIMIT:-900}

/**
 * The date format to use when sending emails. This must be a valid
 * java.text.SimpleDateFormat pattern. Defaults to:
 *
 *  "hh:mm a zzz \'on\' MMMM dd yyyy"
 *
 */
dateFormat = "\"${DATE_FORMAT:-hh:mm a zzz \'on\' MMMM dd yyyy}\""

/*
 * FreeIPA configuration. Possible options
 */
freeipaConfig {
  
  // The hostname that should be used to connect to the Free IPA host
  hostname = "\"${FREEIPA_HOSTNAME}\""
  
  // The Kerberos realm that should be used for authentication
  realm = "\"${FREEIPA_REALM}\""
  
  // The path to the krb5.conf configuration file
  krb5ConfigPath = \"/etc/iris/krb5.conf\"
  
  // The path to the JAAS configuration file
  jaasConfigPath = \"/etc/iris/jaas.conf\"
}

/*
 * The default email config. All other email configurations
 * will inherit from this. Note that the available options
 * for all emailConfigs are:
 * 
 *  smtpHost
 *  smtpPort
 *  smtpFrom
 *  smtpUser
 *  smtpPass
 *  subjectTemplate
 *  messageTemplate
 *  
 */
defaultEmailConfig {
  
  // The SMTP hostname to use for sending emails
  smtpHost = "\"${SMTP_HOST:-smtp.example.com}\""
  
  // The SMTP port to use for sending emails
  smtpPort = "\"${SMTP_PORT:-25}\""
  
  // The address from which the emails should be sent
  smtpFrom = "\"${SMTP_FROM:-freeipa-pwd-portal@example.com}\""
  
  // The username (if needed and different than smtpFrom)
  smtpUser = "\"${SMTP_USER}\""
  if (smtpUser == \"\") {
    smtpUser = null
  }
	
  // The password (if needed) for the above fromAddress
  smtpPass = "\"${SMTP_PASS}\""
  if (smtpPass == \"\") {
    smtpPass = null
  }
}

/*
 * The configuration for the password reset email that is sent to users
 * who have requested a password reset. Available bindings for both the
 * subject and message are:
 *
 *  $name: {@link PasswordResetRequest#getName()}
 *  $requestId: {@link PasswordResetRequest#getRequestId()}
 *  $requestIp: {@link PasswordResetRequest#getRequestIp()}
 *  $requestDate: {@link PasswordResetRequest#getRequestDate()}
 *  $expirationDate: {@link PasswordResetRequest#getExpirationDate()}
 *  $generatedLink: The url generated according to {@link
 *      FreeIPARestService#generateResetLink(PasswordResetRequest)} that the user
 *      will follow to reset their password
 *
 * The default configuration for this looks like:
 *
 *  passwordResetEmailConfig {
 *    subjectTemplate = "Free IPA Password Reset"
 *    messageTemplate = 'Dear $name,\n\n'
 *     + 'The Free IPA Password Portal received a password reset request '
 *     + 'for your account at $requestDate. You can follow the link below '
 *     + 'to fulfill your password reset request; please notify a systems '
 *     + 'administrator immediately if you did not request a password reset '
 *     + 'at this time.\n\n'
 *     + '$generatedLink\n\n'
 *     + 'This link will remain valid until $expirationDate.\n\n'
 *     + 'Sincerely,\n\nFree IPA Password Portal'
 *  }
 */
 passwordResetEmailConfig {}
   
/*
 * The configuration for the password change email that is sent to any
 * user whose password was changed through the password reset portal.
 * Available bindings for both the subject and message are:
 *
 *  $name: The user's LDAP name
 *  $date: The date the password was changed
 *
 * The default configuration for this looks like:
 * 
 *  passwordChangeEmailConfig {
 *    subjectTemplate = "Free IPA Password Change"
 *    messageTemplate = 'Dear $name,\n\n'
 *     + 'Your password was changed using the FreeIPA Password '
 *     + 'portal on $date. Please contact a system administrator '
 *     + 'immediately if you did not change your password at this '
 *     + 'time.\n\n'
 *     + 'Sincerely,\n\nFree IPA Password Portal'  
 *  }
 */
 passwordChangeEmailConfig {}