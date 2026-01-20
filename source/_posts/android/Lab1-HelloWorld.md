---
title: Lab1-Hello World & 环境搭建
date: 2026-01-19 01:00:00
categories: Android
---

本 Lab 将带你完成 Android 开发环境的搭建，克隆并运行 AndroidKotlinPath 项目，学习 Android 项目结构，掌握 Kotlin 基础语法，并了解单应用多 Lab 的架构设计。

<!--more-->

# Lab1-Hello World & 环境搭建

## 📚 学习目标

完成本 Lab 后，你能够：

1. 成功搭建 Android 开发环境并运行 AndroidKotlinPath 项目
2. 理解 Android 项目的基本结构和文件组织
3. 掌握 Kotlin 的基础语法
4. 了解单应用多 Lab 的架构设计
5. 学会使用 Android Studio 的基本功能

---

## 📖 理论知识 (30%)

### 1.1 Android 开发环境

#### Android Studio 介绍
- **什么是 Android Studio**：Google 官方 IDE，基于 IntelliJ IDEA
- **当前版本**：Hedgehog (2023.1.1) 或更高版本
- **系统要求**：
  - Windows 8/10/11 (64-bit)
  - 8 GB RAM 推荐（最低 4 GB）
  - 4 GB 磁盘空间

#### JDK (Java Development Kit)
- **作用**：提供 Kotlin 编译和运行环境
- **Android Studio 自带**：通常内置 JDK 17
- **无需单独安装**：Android Studio 捆绑了完整的 JDK

#### SDK (Software Development Kit)
- **Android SDK**：开发 Android 应用所需的工具集和 API
- **SDK Platform**：不同 Android 版本的 API
- **Build Tools**：编译、打包工具
- **Platform Tools**：adb、fastboot 等工具

#### 环境变量配置
```bash
# Windows 示例
ANDROID_HOME = C:\Users\YourName\AppData\Local\Android\Sdk
Path 添加：%ANDROID_HOME%\platform-tools
```

---

### 1.2 AndroidKotlinPath 项目架构

#### 单应用多 Lab 设计

本项目采用**单应用架构**，将所有 10 个 Lab 集成在一个应用中：

```
AndroidKotlinPath App
├── 主界面（MainActivity）
│   └── RecyclerView 显示 Lab 1-10 列表
├── Lab 1 功能
├── Lab 2 功能
├── ...
└── Lab 10 功能
```

**优势**：
- ✅ 无需切换项目，所有代码集中管理
- ✅ 便于查看前面 Lab 的代码作为参考
- ✅ 复用资源和工具类
- ✅ 体验真实的模块化应用开发

#### 项目结构

```
AndroidKotlinPath/
├── app/                                    # 主应用模块
│   ├── src/
│   │   └── main/
│   │       ├── java/com/nexa/androidkotlinpath/
│   │       │   ├── MainActivity.kt         # 主界面（RecyclerView 导航）
│   │       │   ├── ui/                     # 各 Lab 的 UI 组件
│   │       │   │   ├── lab1/               # Lab 1 相关代码
│   │       │   │   ├── lab2/               # Lab 2 相关代码
│   │       │   │   └── ...
│   │       │   ├── data/                   # 数据层（后续 Lab）
│   │       │   ├── model/                  # 数据模型
│   │       │   └── utils/                  # 工具类
│   │       ├── res/                        # 资源文件
│   │       │   ├── layout/                 # 布局文件
│   │       │   ├── values/                 # 字符串、颜色、样式
│   │       │   ├── drawable/               # 图片资源
│   │       │   └── mipmap/                 # 应用图标
│   │       └── AndroidManifest.xml         # 应用清单文件
│   ├── build.gradle.kts                    # 模块级构建配置
│   └── proguard-rules.pro                  # 混淆规则
├── docs/                                   # 学习文档
│   ├── index.md                            # 学习路径总览
│   ├── Lab1-HelloWorld.md                  # 各 Lab 详细文档
│   └── template.md                         # 文档模板
├── gradle/                                 # Gradle 配置
├── build.gradle.kts                        # 项目构建配置
├── settings.gradle.kts                     # Gradle 设置
└── CLAUDE.md                               # Claude Code 指导文件
```

#### 核心文件说明

**AndroidManifest.xml**
- 应用的配置文件
- 声明所有组件（Activity、Service 等）
- 声明所需权限
- 设置应用图标和主题

**build.gradle.kts (模块级)**
- 配置应用 ID：`com.nexa.androidkotlinpath`
- 配置版本号
- 添加依赖库
- 配置编译选项

**MainActivity.kt**
- 应用入口，显示 Lab 列表
- 使用 RecyclerView 展示所有 Lab
- 处理 Lab 导航逻辑

---

### 1.3 Kotlin 基础语法

#### 变量声明

```kotlin
// val：只读变量（类似 Java 的 final）
val name = "Tom"
val age: Int = 25

// var：可变变量
var count = 0
count = 1  // 可以重新赋值

// 可空类型
val nullable: String? = null  // 可以为 null
val notNull: String = "Hello" // 不能为 null
```

#### 函数定义

```kotlin
// 完整写法
fun greet(name: String): String {
    return "Hello, $name"
}

// 简化写法（单表达式函数）
fun greet(name: String) = "Hello, $name"

// 默认参数
fun greet(name: String, prefix: String = "Hello") = "$prefix, $name"

// 调用
greet("Tom")              // Hello, Tom
greet("Tom", "Hi")        // Hi, Tom
```

#### 类定义

```kotlin
// 普通类
class Person(val name: String, var age: Int)

// 数据类（自动生成 equals, hashCode, toString, copy）
data class User(val name: String, val age: Int)

// 使用
val user = User("Tom", 25)
val (name, age) = user  // 解构
val copied = user.copy(age = 26)  // 复制并修改
```

#### Data Class（数据类）详解

**什么是 Data Class？**
- Data class 是 Kotlin 专门用于存储数据的类
- 自动生成 `equals()`, `hashCode()`, `toString()`, `copy()` 等方法
- 适合用于模型、DTO、响应对象等场景

**基本语法**
```kotlin
data class User(
    val id: Int,
    val name: String,
    val email: String,
    var age: Int = 0  // 带默认值的参数
)
```

**自动生成的方法**

1. **toString()**：生成可读的字符串表示
```kotlin
val user = User(1, "Tom", "tom@example.com", 25)
println(user)  // User(id=1, name=Tom, email=tom@example.com, age=25)
```

2. **equals() 和 hashCode()**：用于比较对象
```kotlin
val user1 = User(1, "Tom", "tom@example.com", 25)
val user2 = User(1, "Tom", "tom@example.com", 25)
println(user1 == user2)  // true（所有属性相等）
println(user1 === user2) // false（不同对象引用）
```

3. **copy()**：复制对象并修改部分属性
```kotlin
val user = User(1, "Tom", "tom@example.com", 25)
val olderUser = user.copy(age = 26)  // 复制并修改 age
println(user)        // User(id=1, name=Tom, email=tom@example.com, age=25)
println(olderUser)   // User(id=1, name=Tom, email=tom@example.com, age=26)
```

4. **componentN()**：支持解构声明
```kotlin
val user = User(1, "Tom", "tom@example.com", 25)
val (id, name, email, age) = user  // 解构
println("ID: $id, Name: $name")  // ID: 1, Name: Tom
```

**在 Android 中的应用**
```kotlin
// Lab 数据模型（本项目使用）
data class LabItem(
    val id: Int,
    val title: String,
    val description: String,
    val difficulty: String
)

// 列表项点击事件
data class ClickEvent(
    val position: Int,
    val item: LabItem,
    val timestamp: Long = System.currentTimeMillis()
)

// 网络请求响应
data class ApiResponse<T>(
    val code: Int,
    val message: String,
    val data: T?
)
```

**Data Class 的要求**
- 主构造函数至少有一个参数
- 所有主构造函数参数必须标记为 `val` 或 `var`
- Data class 不能是 abstract、open、sealed 或 inner
- Data class 可以继承其他类，但不能继承自其他 Data class

**最佳实践**
```kotlin
// ✅ 推荐：使用 data class 存储数据
data class User(
    val id: Int,
    val name: String,
    val email: String
)

// ❌ 不推荐：有业务逻辑的类用普通类
class UserRepository {
    fun getUser(id: Int): User { ... }
    fun saveUser(user: User) { ... }
}

// ✅ data class 可以有普通属性和方法
data class User(
    val id: Int,
    val name: String,
    val email: String
) {
    val displayName: String  // 计算属性
        get() = if (name.length > 10) "${name.take(10)}..." else name

    fun isValidEmail(): Boolean {  // 普通方法
        return email.contains("@")
    }
}
```

#### 空安全

```kotlin
// 安全调用操作符 ?.
val name: String? = null
val length = name?.length  // 如果 name 为 null，返回 null
val length2 = name?.length ?: 0  // Elvis 操作符，如果为 null 返回 0

// 非空断言 !!
val text: String? = "Hello"
val l = text!!.length  // 断言 text 不为 null，如果是 null 会抛出 NPE

// 安全类型转换
val obj: Any = "Hello"
val str = obj as? String  // 如果转换失败返回 null
```

#### 条件表达式

```kotlin
// if 是表达式，可以返回值
val max = if (a > b) a else b

// when 表达式（替代 switch）
when (x) {
    1 -> print("x == 1")
    2 -> print("x == 2")
    else -> print("x is neither 1 nor 2")
}

// when 带条件
when (x) {
    in 1..10 -> print("x 在 1-10 之间")
    !in 10..20 -> print("x 不在 10-20 之间")
    else -> print("其他")
}
```

#### 循环

```kotlin
// for 循环
for (i in 1..10) print(i)  // 1 到 10
for (i in 1 until 10) print(i)  // 1 到 9
for (i in 10 downTo 1) print(i)  // 10 到 1
for (i in 1..10 step 2) print(i)  // 1, 3, 5, 7, 9

// 遍历集合
val items = listOf("apple", "banana", "kiwi")
for (item in items) println(item)

// 遍历带索引
for ((index, value) in items.withIndex()) {
    println("index $index: $value")
}
```

#### 集合操作

```kotlin
// List
val list = listOf(1, 2, 3, 4, 5)
val mutableList = mutableListOf(1, 2, 3)

// Map
val map = mapOf("key1" to "value1", "key2" to "value2")

// 集合操作
val numbers = listOf(1, 2, 3, 4, 5)
val doubled = numbers.map { it * 2 }  // [2, 4, 6, 8, 10]
val evens = numbers.filter { it % 2 == 0 }  // [2, 4]
val sum = numbers.reduce { acc, num -> acc + num }  // 15

// 空安全操作
val nullableList: List<Int>? = null
val size = nullableList?.size ?: 0  // 如果为 null 返回 0
```

---

### 1.4 AndroidManifest.xml 详解

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.nexa.androidkotlinpath">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AndroidKotlinPath">

        <!-- MainActivity：应用的入口，显示 Lab 列表 -->
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- 其他 Lab 的 Activity 将在这里注册 -->

    </application>

</manifest>
```

#### 关键属性说明
- `package`：应用的唯一标识符（com.nexa.androidkotlinpath）
- `android:icon`：应用图标
- `android:label`：应用名称
- `android:theme`：应用主题
- `android:exported="true"`：允许其他应用启动此组件

---

### 1.5 Gradle 构建系统

#### Gradle 是什么？
- 基于 Groovy/Kotlin 的构建工具
- 管理依赖、编译、打包
- 自动化构建流程

#### 版本目录（Version Catalog）

本项目使用 Gradle 版本目录管理依赖（`gradle/libs.versions.toml`）：

```toml
[versions]
agp = "8.13.1"
kotlin = "2.0.21"
coreKtx = "1.10.1"
# ... 其他版本

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
# ... 其他库

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
```

#### 常用 Gradle 命令
```bash
# 构建项目
./gradlew build

# 清理构建
./gradlew clean

# 安装到设备
./gradlew installDebug

# 查看依赖树
./gradlew app:dependencies
```

#### 依赖配置示例
```kotlin
dependencies {
    // AndroidX 核心库
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)

    // Material Design
    implementation(libs.material)

    // ConstraintLayout
    implementation(libs.androidx.constraintlayout)

    // 测试库
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}
```

---

## 💻 代码示例 (40%)

### 2.1 克隆并运行项目

#### 步骤 1：克隆项目
```bash
git clone https://github.com/nexa1024/AndroidKotlinPath.git
cd AndroidKotlinPath
```

#### 步骤 2：打开项目
1. 打开 Android Studio
2. 选择 **File → Open**
3. 选择 AndroidKotlinPath 目录
4. 等待 Gradle 同步完成（第一次可能需要几分钟）

#### 步骤 3：运行项目
**方式 1：点击运行按钮**
- 工具栏绿色三角形 ▶️

**方式 2：快捷键**
- Windows: `Shift + F10`
- Mac: `Control + R`

**方式 3：命令行**
```bash
./gradlew installDebug
```

---

### 2.2 项目结构解析

#### 主要文件说明

```
app/src/main/
├── java/com/nexa/androidkotlinpath/
│   ├── MainActivity.kt              # 主界面，显示 Lab 列表
│   ├── ui/
│   │   ├── lab1/                    # Lab 1 功能模块
│   │   └── ...
│   ├── model/                       # 数据模型
│   │   └── LabItem.kt               # Lab 列表项数据类
│   └── utils/                       # 工具类
├── res/
│   ├── layout/
│   │   ├── activity_main.xml        # 主界面布局
│   │   └── item_lab.xml             # Lab 列表项布局
│   ├── values/
│   │   ├── strings.xml              # 字符串资源
│   │   ├── colors.xml               # 颜色资源
│   │   └── themes.xml               # 主题配置
│   └── mipmap/                      # 应用图标
└── AndroidManifest.xml              # 应用清单
```

---

### 2.3 基础示例：Hello World

#### Lab 数据模型

```kotlin
// model/LabItem.kt
data class LabItem(
    val id: Int,
    val title: String,
    val description: String,
    val difficulty: String  // 初级/中级/高级
)
```

#### 主界面布局

```xml
<!-- res/layout/activity_main.xml -->
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/recyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        tools:listitem="@layout/item_lab" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

#### Lab 列表项布局

```xml
<!-- res/layout/item_lab.xml -->
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="8dp"
    app:cardElevation="4dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <TextView
            android:id="@+id/textViewTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Lab1-Hello World"
            android:textSize="18sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/textViewDescription"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:text="学习 Android 开发环境和 Kotlin 基础"
            android:textSize="14sp" />

        <TextView
            android:id="@+id/textViewDifficulty"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:text="初级"
            android:textColor="@color/green"
            android:textSize="12sp" />

    </LinearLayout>

</com.google.android.material.card.MaterialCardView>
```

#### 颜色资源定义

在使用 `@color/green` 之前，需要先在 `res/values/colors.xml` 中定义颜色：

```xml
<!-- res/values/colors.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- 基础颜色 -->
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>

    <!-- 难度等级颜色 -->
    <color name="green">#4CAF50</color>     <!-- 初级 - 绿色 -->
    <color name="orange">#FF9800</color>    <!-- 中级 - 橙色 -->
    <color name="red">#F44336</color>       <!-- 高级 - 红色 -->

    <!-- 主题颜色 -->
    <color name="primary">#2196F3</color>
    <color name="primary_dark">#1976D2</color>
    <color name="accent">#FF4081</color>
</resources>
```

**在 XML 中引用颜色**：
```xml
<TextView
    android:textColor="@color/green"
    android:background="@color/primary" />
```

**在代码中引用颜色**：
```kotlin
// 方式 1：通过 Context
val greenColor = ContextCompat.getColor(this, R.color.green)

// 方式 2：通过 Resources（需要转换为 RGB）
val greenColor2 = getColor(R.color.green)

// 应用到 TextView
textView.setTextColor(greenColor)
```

**常用颜色参考**：
| 颜色 | 代码 | 说明 |
|------|------|------|
| 黑色 | `#000000` 或 `#FF000000` | 完全透明度为 FF |
| 白色 | `#FFFFFF` 或 `#FFFFFFFF` | |
| 红色 | `#F44336` | Material Design Red |
| 绿色 | `#4CAF50` | Material Design Green |
| 蓝色 | `#2196F3` | Material Design Blue |
| 黄色 | `#FFEB3B` | Material Design Yellow |
| 橙色 | `#FF9800` | Material Design Orange |

**颜色格式说明**：
- `#RGB`：3 位简写，例如 `#000` 表示黑色
- `#ARGB`：4 位简写，第一位是透明度
- `#RRGGBB`：6 位标准格式，最常用
- `#AARRGGBB`：8 位完整格式，包含透明度（Alpha 通道）

---

### 2.4 进阶示例：使用 ViewBinding（推荐）

ViewBinding 是类型安全的视图绑定方式，比 `findViewById` 更好。

#### 启用 ViewBinding

在 `app/build.gradle.kts` 中启用：

```kotlin
android {
    ...
    buildFeatures {
        viewBinding = true
    }
}
```

**⚠️ 重要：生成 ViewBinding 绑定类**

启用 ViewBinding 后，**必须先构建项目**才能生成绑定类。否则会出现 `Unresolved reference 'ActivityMainBinding'` 错误。

**构建步骤**：

1. **方式 1：点击 Android Studio 的同步按钮**
   - 点击编辑器顶部的 "Sync Now" 或者 "Sync Project with Gradle Files" 按钮（大象图标）

2. **方式 2：使用菜单栏**
   - 选择 **File → Sync Project with Gradle Files**

3. **方式 3：重新构建项目**
   - 选择 **Build → Rebuild Project**

4. **方式 4：命令行构建**
   ```bash
   ./gradlew clean build
   ```

**绑定类命名规则**：

ViewBinding 会自动为每个布局文件生成一个绑定类，命名规则为：

| 布局文件名 | 生成的绑定类 |
|-----------|-------------|
| `activity_main.xml` | `ActivityMainBinding` |
| `item_lab.xml` | `ItemLabBinding` |
| `fragment_home.xml` | `FragmentHomeBinding` |
| `dialog_settings.xml` | `DialogSettingsBinding` |

**规则**：将文件名转换为**大驼峰命名（Pascal Case）**，去掉下划线，每个单词首字母大写，末尾加上 `Binding`。

**常见错误和解决方法**：

| 错误信息 | 原因 | 解决方法 |
|---------|------|---------|
| `Unresolved reference 'ActivityMainBinding'` | 绑定类未生成 | 执行 **Build → Rebuild Project** |
| 绑定类生成但属性缺失 | 布局文件中没有 `android:id` | 给控件添加 `android:id` |
| 找不到某个 View 的引用 | View 没有 id | 给需要的 View 添加 `android:id` |

#### 使用 ViewBinding

```kotlin
// MainActivity.kt
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private val labs = listOf(
        LabItem(1, "Lab1-Hello World", "学习 Android 开发环境和 Kotlin 基础", "初级"),
        LabItem(2, "Lab2-UI 基础", "学习布局和控件", "初级"),
        // ... 更多 Lab
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // 设置 RecyclerView
        binding.recyclerView.layoutManager = LinearLayoutManager(this)
        binding.recyclerView.adapter = LabAdapter(labs) { lab ->
            // 点击 Lab 跳转到对应 Activity
            Toast.makeText(this, "点击了 ${lab.title}", Toast.LENGTH_SHORT).show()
        }
    }
}
```

#### 创建 RecyclerView Adapter

在使用 `LabAdapter` 之前，需要先创建 Adapter 类：

```kotlin
// ui/LabAdapter.kt
class LabAdapter(
    private val labs: List<LabItem>,
    private val onLabClick: (LabItem) -> Unit  // 点击回调函数
) : RecyclerView.Adapter<LabAdapter.LabViewHolder>() {

    // ViewHolder：持有 item 的视图引用
    inner class LabViewHolder(private val binding: ItemLabBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(lab: LabItem) {
            binding.textViewTitle.text = lab.title
            binding.textViewDescription.text = lab.description
            binding.textViewDifficulty.text = lab.difficulty

            // 根据难度设置不同颜色
            binding.textViewDifficulty.setTextColor(
                when (lab.difficulty) {
                    "初级" -> ContextCompat.getColor(binding.root.context, R.color.green)
                    "中级" -> ContextCompat.getColor(binding.root.context, R.color.orange)
                    "高级" -> ContextCompat.getColor(binding.root.context, R.color.red)
                    else -> ContextCompat.getColor(binding.root.context, R.color.black)
                }
            )

            // 设置点击事件
            binding.root.setOnClickListener {
                onLabClick(lab)
            }
        }
    }

    // 创建 ViewHolder
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LabViewHolder {
        val binding = ItemLabBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return LabViewHolder(binding)
    }

    // 绑定数据
    override fun onBindViewHolder(holder: LabViewHolder, position: Int) {
        holder.bind(labs[position])
    }

    // 返回数据数量
    override fun getItemCount(): Int = labs.size
}
```

**Adapter 关键概念解释**：

1. **ViewHolder**：缓存 View 引用，避免重复 `findViewById`，提升性能
2. **onCreateViewHolder**：创建新的 ViewHolder 实例（只在创建新 item 时调用）
3. **onBindViewHolder**：将数据绑定到已有的 ViewHolder（每次滚动显示时调用）
4. **getItemCount**：返回列表项数量

**使用 Lambda 回调的好处**：
```kotlin
// ✅ 推荐：使用 Lambda，代码简洁
binding.recyclerView.adapter = LabAdapter(labs) { lab ->
    Toast.makeText(this, "点击了 ${lab.title}", Toast.LENGTH_SHORT).show()
}

// ❌ 不推荐：使用接口，代码冗长
binding.recyclerView.adapter = object : LabAdapter.OnItemClickListener {
    override fun onItemClick(lab: LabItem) {
        Toast.makeText(this, "点击了 ${lab.title}", Toast.LENGTH_SHORT).show()
    }
}
```

**文件组织**：
```
app/src/main/java/com/nexa/androidkotlinpath/
├── MainActivity.kt
├── model/
│   └── LabItem.kt       # 数据类
└── ui/
    └── LabAdapter.kt    # Adapter 类
```

**Gradle 依赖**：

确保 `app/build.gradle.kts` 中有 RecyclerView 依赖（Material 库已包含）：

```kotlin
dependencies {
    implementation(libs.material)  // Material Design 包含 RecyclerView
}
```

#### ViewBinding 的优势
- ✅ **类型安全**：编译时检查，避免类型转换错误
- ✅ **空安全**：避免空指针异常
- ✅ **代码简洁**：无需 `findViewById`
- ✅ **性能优秀**：无运行时开销

---

### 2.5 模拟器设置

#### 创建虚拟设备

1. **Tools → Device Manager**
2. 点击 **Create Device**
3. 选择设备型号：
   - **推荐**：Pixel 6, Pixel 7
   - 屏幕尺寸：任意
4. 选择系统镜像：
   - **推荐**：API 33 (Android 13) 或更高
5. 完成创建

#### 运行应用

**方式 1：点击运行按钮**
- 工具栏绿色三角形 ▶️

**方式 2：快捷键**
- Windows: `Shift + F10`
- Mac: `Control + R`

**方式 3：命令行**
```bash
./gradlew installDebug
```

---

## 🎯 实践任务 (30%)

### 必做题（2-3 个）

#### 任务 1：理解项目结构

**需求**：
- 浏览 AndroidKotlinPath 项目的所有文件夹
- 理解每个文件夹的作用
- 找到 MainActivity.kt 并阅读代码

**要求**：
- 列出项目中主要文件夹的作用
- 说明单应用架构的优势
- 理解 MainActivity 的作用

---

#### 任务 2：修改 Lab 列表

**需求**：
- 修改 `strings.xml` 添加新的字符串资源
- 更新 Lab 列表数据
- 观察界面变化

**要求**：
- 在 `res/values/strings.xml` 中定义至少 3 个字符串
- 修改 MainActivity 中的 Labs 列表
- 重新运行应用查看效果

**提示**：
```xml
<!-- res/values/strings.xml -->
<resources>
    <string name="app_name">AndroidKotlinPath</string>
    <string name="lab_list_title">学习路径</string>
    <string name="welcome_message">欢迎学习 Android 开发</string>
</resources>
```

```kotlin
// 在代码中使用
getString(R.string.lab_list_title)
```

---

#### 任务 3：添加点击反馈

**需求**：
- 为 RecyclerView 的 item 添加点击效果
- 点击 Lab 时显示 Toast 提示
- 添加点击动画效果

**要求**：
- 使用 Toast 显示点击的 Lab 信息
- 为 item 添加点击波纹效果
- 使用 Log 输出点击日志

**参考代码**：
```kotlin
binding.recyclerView.adapter = LabAdapter(labs) { lab ->
    Toast.makeText(this, "你点击了：${lab.title}", Toast.LENGTH_SHORT).show()
    Log.d("MainActivity", "点击 Lab: ${lab.id} - ${lab.title}")
}
```

```xml
<!-- item_lab.xml 添加点击效果 -->
<com.google.android.material.card.MaterialCardView
    ...
    android:clickable="true"
    android:focusable="true"
    android:foreground="?android:attr/selectableItemBackground">
    ...
</com.google.android.material.card.MaterialCardView>
```

---

### 挑战题（1 个）

#### 挑战：创建简单的计数器功能

**需求**：
- 在项目中添加一个简单的计数器 Activity
- 从主界面点击某个 Lab 时跳转到计数器
- 实现加减功能

**步骤提示**：

1. **创建 Activity**：
   - 在 `ui/lab1/` 下创建 `CounterActivity.kt`
   - 创建布局文件 `activity_counter.xml`

2. **布局文件**：
```xml
<!-- res/layout/activity_counter.xml -->
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="16dp">

    <TextView
        android:id="@+id/textViewCount"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="0"
        android:textSize="48sp" />

    <LinearLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="32dp"
        android:orientation="horizontal">

        <Button
            android:id="@+id/buttonDecrease"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginEnd="16dp"
            android:text="-" />

        <Button
            android:id="@+id/buttonIncrease"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="+" />

    </LinearLayout>

</LinearLayout>
```

3. **Activity 代码**：
```kotlin
class CounterActivity : AppCompatActivity() {

    private lateinit var binding: ActivityCounterBinding
    private var count = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCounterBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.buttonIncrease.setOnClickListener {
            count++
            updateCount()
        }

        binding.buttonDecrease.setOnClickListener {
            if (count > 0) {
                count--
                updateCount()
            }
        }
    }

    private fun updateCount() {
        binding.textViewCount.text = count.toString()
    }
}
```

4. **在 AndroidManifest.xml 中注册**：
```xml
<activity
    android:name=".ui.lab1.CounterActivity"
    android:exported="false" />
```

5. **从 MainActivity 跳转**：
```kotlin
// 在点击事件中添加
val intent = Intent(this, CounterActivity::class.java)
startActivity(intent)
```

---

## ✅ 验收标准

完成本 Lab 后，请确保：

- [ ] 成功克隆并运行了 AndroidKotlinPath 项目
- [ ] 理解项目结构中每个文件夹的作用
- [ ] 掌握 Kotlin 的基础语法（变量、函数、类、空安全）
- [ ] 理解单应用多 Lab 的架构设计
- [ ] 熟练使用 ViewBinding
- [ ] 能够处理基本的点击事件
- [ ] 完成了至少 2 个必做题
- [ ] 应用在模拟器上正常运行无崩溃

---

## 📚 扩展阅读

### 官方文档
- [Android Developers](https://developer.android.com/)
- [Kotlin 官方文档](https://kotlinlang.org/docs/home.html)
- [Gradle 官方文档](https://docs.gradle.org/)

### 推荐工具
- **ADB 命令**：
  ```bash
  adb devices              # 查看连接的设备
  adb install app.apk      # 安装应用
  adb logcat              # 查看日志
  adb shell screencap -p > screen.png  # 截图
  ```

- **Android Studio 快捷键**：
  - `Ctrl + B`：跳转到定义
  - `Ctrl + Alt + L`：格式化代码
  - `Ctrl + /`：注释/取消注释
  - `Alt + Enter`：快速修复
  - `Ctrl + N`：快速查找类

---

## 🔑 关键要点总结

1. **AndroidKotlinPath** 采用单应用架构，所有 Lab 集成在一个项目中
2. **项目结构** 分为 `java/`（代码）、`res/`（资源）、`AndroidManifest.xml`（配置）
3. **Kotlin** 是 Android 开发的首选语言，具有空安全、简洁等特性
4. **ViewBinding** 是推荐的视图绑定方式，比 `findViewById` 更安全
5. **Gradle** 使用版本目录管理依赖，所有版本集中在 `libs.versions.toml`
6. **AndroidManifest.xml** 是应用的配置文件，必须声明所有组件

---

**下一步**：完成本 Lab 后，继续学习 **Lab2-UI 基础 & 布局与控件**
