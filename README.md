# DC-CardRecognize

## 简介
DC-CardDetect插件是基于百度文字识别SDK创建的uni插件，该插件现已支持身份证正反面识别，银行卡识别，车牌号识别。

### 准备
请前往[百度开发平台](http://ai.baidu.com/tech/ocr)申请账号，出于安全考虑，百度推荐使用授权文件方式进行开发者认证，请各位开发者申请应用之前务必认真阅读文档[http://ai.baidu.com/docs#/OCR-Android-SDK/7bb09719](http://ai.baidu.com/docs#/OCR-Android-SDK/7bb09719)。

**下载License文件授权文件** <br>
应用创建成功之后，点击应用列表，选择已创建的应用对应的管理按钮，点击管理按钮 <br>

- “下载License文件-iOS（文字识别）”，将下载下来的License文件替换插件目录DC-CardDetect/ios/中的同名文件。

**重要：插件中自带aip.license为测试使用，切记换成申请的License**

### 须知

百度文字识别对所有用户均提供每天有限次数的免费使用服务，如有更大需求，需开通付费。

当前插件基于网络使用，使用时请确保网络通畅。


##  此工程运行方法
### 1.clone 本工程
`git clone https://github.com/xiaohuapunk/DC-CardRecognize.git`

### 2.将本工程引入到 5+离线SDK的 HBuilder-uniPluginDemo 工程中
### 3.在 HBuilder-Integrate-Info.plist 的 `dcloud_uniplugins` 节点下添加如下配置
```
<dict>
	<key>hooksClass</key>
   	<string></string>
   	<key>plugins</key>
        <array>
            	<dict>
                    <key>class</key>
                    <string>DCCardDetectModule</string>
                    <key>name</key>
                    <string>DC-CardDetect</string>
                    <key>type</key>
                    <string>module</string>
              </dict>
      </array>
</dict>
```

### 4.添加相册，及相机使用权限
- "NSCameraUsageDescription",
- "NSPhotoLibraryUsageDescription"
