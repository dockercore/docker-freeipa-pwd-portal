import ch.qos.logback.classic.encoder.PatternLayoutEncoder
import ch.qos.logback.core.rolling.FixedWindowRollingPolicy
import ch.qos.logback.core.rolling.RollingFileAppender
import ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy
import ch.qos.logback.core.status.OnConsoleStatusListener

import static ch.qos.logback.classic.Level.*

/*
 * The default logging configuration. Logs to:
 * 
 *  /var/log/freeipa-pwd-portal/application.log
 *  
 *  using a RollingFileAppender. This is mostly stolen
 *  from:
 *  
 *  http://jdpgrailsdev.github.io/blog/2014/06/17/logback_tomcat_rolling_appender.html
 */

appender("ROLLING_FILE", RollingFileAppender) {
    file = "/var/log/freeipa-pwd-portal/application.log"
    encoder(PatternLayoutEncoder) {
      pattern = "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%X{req.remoteHost}] %-5level %logger{0} - %msg%n"
    }
    triggeringPolicy(SizeBasedTriggeringPolicy) {
        maxFileSize = '10MB'
    }
    rollingPolicy(FixedWindowRollingPolicy) {
        fileNamePattern = "/var/log/freeipa-pwd-portal/application-%d{yyyyMMdd_hhmmss}.%i.gz"
        maxIndex = 10
    }
}

logger("org.apache.cxf.phase.PhaseInterceptorChain", ERROR)
logger("com.xetus", INFO, ["ROLLING_FILE"], false)
root(WARN, ["ROLLING_FILE"])
