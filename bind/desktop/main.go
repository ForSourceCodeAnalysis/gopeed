package main

import "C"
import (
	"encoding/json"

	"github.com/GopeedLab/gopeed/pkg/rest"
	"github.com/GopeedLab/gopeed/pkg/rest/model"
)

func main() {}

//export Start
func Start(cfg *C.char) (int, *C.char) {
	// 这个函数可以被其他语言调用，这里是C语言
	var config model.StartConfig
	if err := json.Unmarshal([]byte(C.GoString(cfg)), &config); err != nil {
		return 0, C.CString(err.Error())
	}
	//会启动一个http服务，提供API供UI使用
	realPort, err := rest.Start(&config)
	if err != nil {
		return 0, C.CString(err.Error())
	}
	return realPort, nil
}

//export Stop
func Stop() {
	rest.Stop()
}
