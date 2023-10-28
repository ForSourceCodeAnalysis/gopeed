import 'package:json_annotation/json_annotation.dart';

//定义自动生成的文件名称
part 'start_config.g.dart';

//注解，运行dart run build_runner build命令时，会根据注解自动生成相关代码
@JsonSerializable()
class StartConfig {
  late String network;
  late String address;
  late String storage;
  late String storageDir;
  late int refreshInterval;
  late String apiToken;

  StartConfig();
//下面两个方法是通用的方法，json序列化反序列化时自动调用这两个方法
  factory StartConfig.fromJson(Map<String, dynamic> json) =>
      //这种形式是一种惯例，也可以改成其他的名称，但是这种参考官方示例的形式更规范
      _$StartConfigFromJson(json);

  Map<String, dynamic> toJson() => _$StartConfigToJson(this);
}
