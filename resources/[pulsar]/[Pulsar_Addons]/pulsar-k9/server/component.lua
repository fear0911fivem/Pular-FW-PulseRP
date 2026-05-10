Logger = {
	Info = function(_, tag, msg)
		exports["pulsar-core"]:LoggerInfo(tag, msg)
	end,
	Critical = function(_, tag, msg)
		exports["pulsar-core"]:LoggerError(tag, msg)
	end,
}
