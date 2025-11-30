extends Control

var urls = ""
var file_name = "descarga.rar"
var sizefile = 0
var progress = 0
var dir = DataGame.documentos+"/CUPI/Levels"

func _ready() -> void:
	var http = HTTPRequest.new()
	downloadFile(urls,"",http)
func downloadFile(url,path,http:HTTPRequest):
	if url != "":
		http.set_download_file(path)
		http.request(url)
