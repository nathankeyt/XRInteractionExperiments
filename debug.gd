extends Node

signal print_log(log: String)

func log(log: String):
	print_log.emit(log)
