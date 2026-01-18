---
title: Android-Day01-搭建基础工程+ToolBar容器
date: 2026-1-15 00:00:00
categories: Android
---

## Day01：搭建基础工程 + Toolbar 容器
创建 Empty Views Activity 项目，配置国内镜像加速依赖下载，搭建 Toolbar 和 Fragment 容器作为应用基础架构。

**核心内容**：项目初始化、Gradle镜像配置、Toolbar集成、Fragment容器搭建

<!--more-->

# 新建项目
1. 选择Empty Views Activity(**重要，选择其他的可能会使用Jetpack Compose**)
2. minSdk 33
3. targetSdk 36

# 镜像问题
## 修改gradle到国内镜像
路径：项目根目录\gradle\wrapper\gradle-wrapper.properties

将原有的gradle.org修改为阿里云镜像

```plain
distributionUrl=https://mirrors.aliyun.com/macports/distfiles/gradle/gradle-8.13-all.zip
#distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-all.zip
```

## 修改插件和库依赖到国内镜像
插件为项目提供构建、测试、打包等能力，库提供可复用的代码/资源

### AndroidStudio较新版本 (例如 Arctic Fox 2021.3.1 及之后)
+ 项目根目录存在settings.gradle,在文件当中会存在pluginManagement和 dependencyResolutionManagement代码块。

### AndroidStudio旧版本 (2021.3.1 之前)
+ 项目根目录下的 `build.gradle`或 `build.gradle.kts`
+ 主要的仓库配置在根目录的 `build.gradle`文件的 `buildscript`和 `allprojects`部分。

### settings.gradle
```plain
pluginManagement {
    repositories {
        // 插件新加3行
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        // 库加2行
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
    }
}

rootProject.name = "PerfStabilityLab"
include(":app")

```

# 搭建项目骨架
## 避免系统自带标题栏和ToolBar冲突
使用NoActionBar，res/values/themes.xml（或 styles.xml，看你工程生成的名字）确认类似：

```plain
<style name="Theme.PerfStabilityLab" parent="Theme.Material3.DayNight.NoActionBar">
    <!-- 其他颜色配置随便 -->
</style>
```

 并检查 AndroidManifest.xml 里 Application 或 Activity 使用了这个主题：

```plain
<application
    android:theme="@style/Theme.PerfStabilityLab" ... />
```

 

## 在activity_main.xml修改布局
用LinearLayout比较直观，改成上下结构，放置一个MaterialToolbar和FragmentContainerView

```plain
<?xml version="1.0" encoding="utf-8"?>
  <LinearLayout
      xmlns:android="http://schemas.android.com/apk/res/android"
      xmlns:app="http://schemas.android.com/apk/res-auto"
      android:orientation="vertical"
      android:layout_width="match_parent"
      android:layout_height="match_parent">

      <com.google.android.material.appbar.MaterialToolbar
          android:id="@+id/toolbar"
          android:layout_width="match_parent"
          android:layout_height="wrap_content"
          app:title="PerfStabilityLab" />

      <androidx.fragment.app.FragmentContainerView
          android:id="@+id/main_container"
          android:layout_width="match_parent"
          android:layout_height="0dp"
          android:layout_weight="1" />
  </LinearLayout>
```

<!-- 这是一张图片，ocr 内容为： -->
![](/images/android/Day01-skeleton_toolbar/01.png)

## ToolBar设置为ActionBar，放占位Fragment
### 新建Fragment，命名为PlaceholderFragment
放入一个占位的TextView即可，新建Fragment的时候会自动生成PlaceholderFragment.kt

```plain
# res/layout/fragment_placeholder.xml：

<TextView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:text="Placeholder" />
```

## MainActivity修改
```plain
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        // 设置ActionBar
        val toolBar = findViewById<MaterialToolbar>(R.id.toolbar)
        setSupportActionBar(toolBar)

        // 把状态栏/刘海区域的高度加到 toolbar 的 top padding
        val initialTopPadding = toolBar.paddingTop
        ViewCompat.setOnApplyWindowInsetsListener(toolBar) { v, insets ->
            val topInset = insets.getInsets(WindowInsetsCompat.Type.statusBars()).top
            v.updatePadding(top = initialTopPadding + topInset)
            insets
        }
        ViewCompat.requestApplyInsets(toolBar)

        // 先设置左上角返回按钮点击事件，day2再做显示隐藏逻辑
        toolBar.setNavigationOnClickListener {
            onBackPressedDispatcher.onBackPressed()
        }

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.main_container, PlaceholderFragment())
                .commit()
        }
    }
}
```

# 运行测试，确认项目骨架最小集可用
<!-- 这是一张图片，ocr 内容为： -->
![](/images/android/Day01-skeleton_toolbar/02.png)

