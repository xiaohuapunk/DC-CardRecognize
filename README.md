# DC-CardRecognize
基于百度文字识别SDK实现的uni-app 原生插件

# 运行方法
### 1.clone 本工程
`git clone https://github.com/xiaohuapunk/DC-CardRecognize.git`

2.将本工程引入到 5+离线SDK/HBuilder-uniPluginDemo 工程中
3.在 HBuilder-Integrate-Info.plist 的 `dcloud_uniplugins` 节点下添加如下配置
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
