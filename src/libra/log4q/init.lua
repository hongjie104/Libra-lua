--
-- Author: zhouhongjie@apowo.com
-- Date: 2015-03-13 10:27:56
--

logger = import(".Logger").new()

-- DEBUG:用来debug的信息
-- INFO:有用或者无用的信息
-- WARN:警告
-- ERROR:错误
-- FATAL:致命性错误
LOG_LEVEL = LOG_LEVEL or {DEBUG = true, INFO = true, WARN = true, ERROR = true, FATAL = true}