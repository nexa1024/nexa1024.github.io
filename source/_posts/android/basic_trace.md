---
title: 基于Find Cpu HotSpots分析调用栈
date: 2025-12-27 00:00:00
categories: android analysis
hide: true
---

通过Find Cpu HotSpots分析调用栈，在对项目代码不熟悉的情况下，能帮助我们尽快定位对应的入口与触发的函数。

<!--more-->

# 前置准备

## 真机调试和远程屏幕准备

真机打开开发者选项和调试模式，参考这个url或自行搜索即可https://developer.android.google.cn/studio/debug/dev-options?hl=zh-cn

在github下载QtScrcpy,https://github.com/barry-ran/QtScrcpy/releases

当**真机打开了usb调试之后**，打开QtScrcpy软件，能看到我们的真机，双击打开就可以显示屏幕，我们在电脑上远程操作真机屏幕，不用运行虚拟机，节省一些资源。

![](/images/android/basic_trace/sc1.png)

![](/images/android/basic_trace/sc2.png)

## 官方项目准备

这里以官方的示例项目的jetnews作为我们的演示项目https://github.com/android/compose-samples

### gradle镜像配置

```
// jetnews/gradle/wrapper/gradle-wrapper.properties
// 修改为aliyun镜像，并且gradle-8.13-bin.zip可以修改为gradle-8.13-all.zip
distributionUrl=https\://mirrors.aliyun.com/macports/distfiles/gradle/gradle-8.13-all.zip
```

### 插件镜像

```
// jetnews/setting.gradle.kts
pluginManagement {
    repositories {
        maven { url=uri ("https://www.jitpack.io")}
        maven { url=uri ("https://maven.aliyun.com/repository/releases")}
        maven { url=uri ("https://maven.aliyun.com/repository/google")}
        maven { url=uri ("https://maven.aliyun.com/repository/central")}
        maven { url=uri ("https://maven.aliyun.com/repository/gradle-plugin")}
        maven { url=uri ("https://maven.aliyun.com/repository/public")}
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        snapshotVersion?.let {
            println("https://androidx.dev/snapshots/builds/$it/artifacts/repository/")
            maven { url = uri("https://androidx.dev/snapshots/builds/$it/artifacts/repository/") }
        }
        maven { url=uri ("https://www.jitpack.io")}
        maven { url=uri ("https://maven.aliyun.com/repository/releases")}
        maven { url=uri ("https://maven.aliyun.com/repository/google")}
        maven { url=uri ("https://maven.aliyun.com/repository/central")}
        maven { url=uri ("https://maven.aliyun.com/repository/gradle-plugin")}
        maven { url=uri ("https://maven.aliyun.com/repository/public")}
        google()
        mavenCentral()
    }
}
```

### 安装app到真机

![](/images/android/basic_trace/sc3.png)

# 录制trace文件

先打开profile，不然看不到录制入口
![](/images/android/basic_trace/sc4.png)


选择进程，Find Cpu Spots, 开始录制
![](/images/android/basic_trace/sc5.png)

开始录制后根据要求操作屏幕，可以是点击跳转，滑动等，操作完屏幕点击停止录制，会生成trace文件，我们可以导出trace文件

![](/images/android/basic_trace/sc6.png)

# 分析trace文件

打开这个url https://profiler.firefox.com/，将trace文件拖入网页

因为app运行在主线程，点击main和栈图，筛选输入click，查看绿色部分，可以发现点击的时候，触发了一堆包下的方法，那么知道了这些包名和方法，就可以通过全局搜索查到对应的入口了

![](/images/android/basic_trace/sc7.png)

