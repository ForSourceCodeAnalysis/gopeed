package main

import "C" //这句话是告诉Go编译程序在编译前先运行cgo工具
import (
	"encoding/json"

	"github.com/GopeedLab/gopeed/pkg/rest"
	"github.com/GopeedLab/gopeed/pkg/rest/model"
)

func main() {}

//export Start
func Start(cfg *C.char) (int, *C.char) {
	//上面的export start指示编译器这个函数需要导出给外部使用，会自动生成头文件
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
