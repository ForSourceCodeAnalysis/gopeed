package model

import (
	"encoding/base64"
	"io/fs"
)

type Storage string

const (
	StorageMem  Storage = "mem"
	StorageBolt Storage = "bolt"
)

type StartConfig struct {
	Network         string  `json:"network"`         //网络类型，默认tcp
	Address         string  `json:"address"`         //监听地址，包括端口
	RefreshInterval int     `json:"refreshInterval"` //刷新间隔
	Storage         Storage `json:"storage"`         //存储类型
	StorageDir      string  `json:"storageDir"`      //存储目录
	ApiToken        string  `json:"apiToken"`        //api token

	WebEnable    bool          //是否使能web
	WebFS        fs.FS         //web文件系统
	WebBasicAuth *WebBasicAuth //web认证
}

// 配置初始化
func (cfg *StartConfig) Init() *StartConfig {
	if cfg.Network == "" {
		cfg.Network = "tcp"
	}
	if cfg.Address == "" {
		cfg.Address = "127.0.0.1:0" //端口是0时，会自动选择一个可用的随机端口
	}
	if cfg.RefreshInterval == 0 {
		cfg.RefreshInterval = 350
	}
	if cfg.Storage == "" {
		cfg.Storage = StorageBolt
	}
	if cfg.StorageDir == "" {
		cfg.StorageDir = "./"
	}
	return cfg
}

type WebBasicAuth struct {
	Username string
	Password string
}

// Authorization returns the value of the Authorization header to be used in HTTP requests.
func (cfg *WebBasicAuth) Authorization() string {
	userId := cfg.Username + ":" + cfg.Password
	return "Basic " + base64.StdEncoding.EncodeToString([]byte(userId))
}
