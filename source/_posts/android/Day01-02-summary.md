---
title: Android-Day-01-02 实现总结
date: 2026-1-18 00:00:00
categories: Android
---

## PerfStabilityLab：性能与稳定性演示项目
**PerfStabilityLab** 是一个专注于 Android 性能与稳定性优化的演示项目，通过动手实验的方式复现启动优化、卡顿、内存泄漏、OOM、ANR、Crash 等典型问题。

**技术栈**：Kotlin + View/XML + 单Activity + Fragment架构 (SDK 33-36)

**Day01-02**：搭建项目骨架（Toolbar+Fragment容器）+ RecyclerView导航链路

<!--more-->

## 项目概述

**PerfStabilityLab** 是一个专注于性能与稳定性的 Android 演示项目，通过动手实验的方式复现应用优化。

### 技术栈
- **语言**: Kotlin
- **最低 SDK**: 33 (Android 13)
- **目标 SDK**: 36
- **UI**: View/XML 布局（非 Jetpack Compose）
- **架构**: 单 Activity + Fragment 导航

---

## Day 1：项目骨架 + 导航容器

### 目标
搭建项目基础，配置 Toolbar 和 Fragment 容器，为后续实验做准备。

### 实现步骤

#### 1. 项目初始化
创建新的 Android 项目，配置：
- Kotlin 作为主要语言
- 基于 View/XML 的 UI
- Material Design 组件

#### 2. MainActivity 结构
**文件**: `app/src/main/java/com/nexa/perfstabilitylab/MainActivity.kt`

```kotlin
package com.nexa.perfstabilitylab

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import com.google.android.material.appbar.MaterialToolbar
import com.nexa.perfstabilitylab.core.LabId
import com.nexa.perfstabilitylab.ui.home.LabListFragment
import com.nexa.perfstabilitylab.ui.lab.*

class MainActivity : AppCompatActivity() {

    // 保存 Toolbar 引用，用于后续控制导航图标
    private lateinit var toolbar: MaterialToolbar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 启用边到边显示，实现现代 Android 全屏效果
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        // 设置 MaterialToolbar 作为 ActionBar
        toolbar = findViewById(R.id.toolbar)
        setSupportActionBar(toolbar)

        // 处理状态栏 insets - 将状态栏高度添加到 Toolbar 的 top padding
        // 这样确保内容不会被状态栏遮挡
        val initialTopPadding = toolbar.paddingTop
        ViewCompat.setOnApplyWindowInsetsListener(toolbar) { v, insets ->
            // 获取状态栏 insets（刘海/摄像头区域）
            val topInset = insets.getInsets(WindowInsetsCompat.Type.statusBars()).top
            // 更新 Toolbar padding 以适应状态栏
            v.updatePadding(top = initialTopPadding + topInset)
            insets
        }
        // 请求初始 insets 应用
        ViewCompat.requestApplyInsets(toolbar)

        // 设置导航按钮点击监听（返回按钮）
        toolbar.setNavigationOnClickListener {
            // 使用现代的 onBackPressedDispatcher 而非已弃用的 onBackPressed()
            onBackPressedDispatcher.onBackPressed()
        }

        // 监听返回栈变化，控制导航图标显示/隐藏
        // Day 2 要求：根据当前页面显示/隐藏返回箭头
        supportFragmentManager.addOnBackStackChangedListener {
            updateNavigationIcon()
        }

        // 初始设置：加载实验列表 Fragment
        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.main_container, LabListFragment())
                .commit()
        }

        // 初始化导航图标状态（列表页应隐藏返回箭头）
        updateNavigationIcon()
    }

    /**
     * 导航到指定的实验页面
     * @param labId 要打开的实验 ID
     */
    fun openLab(labId: LabId) {
        // 根据 Lab ID 创建对应的 Fragment
        val fragment = when (labId) {
            LabId.STARTUP -> StartupLabFragment()
            LabId.JANK -> JankLabFragment()
            LabId.LEAK -> LeakLabFragment()
            LabId.OOM -> OomLabFragment()
            LabId.ANR -> AnrLabFragment()
            LabId.CRASH -> CrashLabFragment()
        }

        // 从注册表获取实验信息并更新 Toolbar 标题
        val labItem = com.nexa.perfstabilitylab.core.LabRegistry.getLabById(labId)
        supportActionBar?.title = labItem?.title ?: "实验"

        // 替换 Fragment 并添加到返回栈
        // 这样用户可以返回到列表
        supportFragmentManager.beginTransaction()
            .replace(R.id.main_container, fragment)
            .addToBackStack(labId.id)  // 使用实验 ID 作为返回栈名称
            .commit()
    }

    /**
     * 根据当前返回栈状态更新导航图标
     * - 列表页（无返回栈）：隐藏返回箭头，显示应用名称
     * - 实验页（有返回栈）：显示返回箭头，显示实验标题
     */
    private fun updateNavigationIcon() {
        val hasBackStack = supportFragmentManager.backStackEntryCount > 0
        if (hasBackStack) {
            // 在实验 Fragment 时显示返回箭头
            toolbar.setNavigationIcon(com.google.android.material.R.drawable.abc_ic_ab_back_material)
        } else {
            // 在列表屏幕时隐藏返回箭头
            toolbar.navigationIcon = null
            supportActionBar?.title = "PerfStabilityLab"
        }
    }
}
```

**关键点**:
- 使用 `enableEdgeToEdge()` 实现现代边到边显示
- 通过 `WindowInsetsCompat` 正确处理状态栏 insets
- 实现 `addOnBackStackChangedListener` 动态控制导航图标
- 使用现代的 `onBackPressedDispatcher` 替代已弃用的 `onBackPressed()`

#### 3. 布局结构

**文件**: `app/src/main/res/layout/activity_main.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- 根布局使用 LinearLayout 实现垂直排列 -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <!-- Material Toolbar 作为 ActionBar -->
    <com.google.android.material.appbar.MaterialToolbar
        android:id="@+id/toolbar"
        android:layout_width="match_parent"
        android:layout_height="?attr/actionBarSize"
        android:background="?attr/colorPrimary" />

    <!-- Fragment 导航容器 -->
    <!-- 所有 Fragment 将在此处显示 -->
    <androidx.fragment.app.FragmentContainerView
        android:id="@+id/main_container"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

</LinearLayout>
```

---

## Day 2：实验列表 + 导航系统

### 目标
创建基于 RecyclerView 的实验列表，实现导航到各个实验 Fragment，并正确管理返回栈。

### 实现步骤

#### 1. LabId 枚举 - 类型安全的实验标识符

**文件**: `app/src/main/java/com/nexa/perfstabilitylab/core/LabId.kt`

```kotlin
package com.nexa.perfstabilitylab.core

/**
 * 实验ID枚举，提供类型安全的实验标识
 * 每个枚举值代表一个性能/稳定性主题
 */
enum class LabId(val id: String) {
    STARTUP("startup"),    // 启动优化
    JANK("jank"),          // 掉帧/卡顿
    LEAK("leak"),          // 内存泄漏
    OOM("oom"),            // 内存溢出
    ANR("anr"),            // 应用无响应
    CRASH("crash");        // 崩溃与稳定性

    companion object {
        /**
         * 根据字符串 ID 查找 LabId
         * @return 匹配的 LabId，未找到返回 null
         */
        fun fromId(id: String): LabId? {
            return values().find { it.id == id }
        }
    }
}
```

**为什么使用枚举？**
- **类型安全**: 编译器在编译时检查有效性
- **避免魔法字符串**: 集中管理 ID
- **易于扩展**: 添加新实验只需添加枚举值

#### 2. LabItem 数据模型

**文件**: `app/src/main/java/com/nexa/perfstabilitylab/core/LabItem.kt`

```kotlin
package com.nexa.perfstabilitylab.core

/**
 * 实验项数据模型
 * @param labId 实验的枚举 ID
 * @param title 列表中显示的标题
 * @param desc 实验涵盖内容的简要描述
 * @param tags 分类标签列表（可选，默认为空）
 */
data class LabItem(
    val labId: LabId,
    val title: String,
    val desc: String,
    val tags: List<String> = emptyList()
) {
    // 暴露字符串 ID 以保持向后兼容
    val id: String get() = labId.id
}
```

**设计决策**:
- 使用 `LabId` 枚举而非原始字符串以提供类型安全
- `tags` 是可选参数，默认为空列表
- 暴露 `id` 属性以兼容基于字符串的 API

#### 3. LabRegistry - 集中式实验管理

**文件**: `app/src/main/java/com/nexa/perfstabilitylab/core/LabRegistry.kt`

```kotlin
package com.nexa.perfstabilitylab.core

/**
 * 所有实验的中央注册表
 * 使用 object 声明（单例模式）实现全局访问
 */
object LabRegistry {

    // 所有可用实验的完整列表
    val allLabs: List<LabItem> = listOf(
        LabItem(
            labId = LabId.STARTUP,
            title = "启动优化",
            desc = "冷/温/热启动、初始化治理、首帧直觉",
            tags = listOf("冷启动", "温启动", "热启动", "首帧", "初始化")
        ),
        LabItem(
            labId = LabId.JANK,
            title = "卡顿 / Jank",
            desc = "主线程阻塞、IO、锁等待、UI/GC",
            tags = listOf("主线程", "IO", "锁", "布局", "GC")
        ),
        LabItem(
            labId = LabId.LEAK,
            title = "内存泄漏",
            desc = "引用链、生命周期注销",
            tags = listOf("引用链", "生命周期", "LeakCanary")
        ),
        LabItem(
            labId = LabId.OOM,
            title = "OOM",
            desc = "峰值、Bitmap、缓存上限、降级",
            tags = listOf("Bitmap", "缓存", "内存抖动", "降级")
        ),
        LabItem(
            labId = LabId.ANR,
            title = "ANR",
            desc = "无响应、主线程卡死/等待",
            tags = listOf("主线程", "锁", "Binder", "Trace")
        ),
        LabItem(
            labId = LabId.CRASH,
            title = "Crash",
            desc = "栈+上下文、定位与闭环",
            tags = listOf("异常", "日志", "混淆", "监控")
        )
    )

    /**
     * 根据 LabId 枚举获取实验信息
     * @return 找到的 LabItem，未找到返回 null
     */
    fun getLabById(id: LabId): LabItem? {
        return allLabs.find { it.labId == id }
    }

    /**
     * 根据字符串 ID 获取实验信息
     * @return 找到的 LabItem，未找到返回 null
     */
    fun getLabById(id: String): LabItem? {
        return LabId.fromId(id)?.let { getLabById(it) }
    }
}
```

**优势**:
- 实验数据的唯一真实来源
- 易于添加新实验或修改现有实验
- Object 声明确保只有一个实例存在
- 同时提供基于枚举和基于字符串的查找方法

#### 4. 实验列表 Fragment

**文件**: `app/src/main/java/com/nexa/perfstabilitylab/ui/home/LabListFragment.kt`

```kotlin
package com.nexa.perfstabilitylab.ui.home

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.nexa.perfstabilitylab.MainActivity
import com.nexa.perfstabilitylab.R
import com.nexa.perfstabilitylab.core.LabRegistry

/**
 * 主列表屏幕，显示所有可用实验
 * 用户点击项目导航到对应的实验 Fragment
 */
class LabListFragment : Fragment(R.layout.fragment_lab_list) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // 从布局获取 RecyclerView
        val rv = view.findViewById<RecyclerView>(R.id.rv_labs)

        // 使用 LinearLayoutManager 实现垂直列表
        rv.layoutManager = LinearLayoutManager(requireContext())

        // 从注册表获取实验数据
        val items = LabRegistry.allLabs

        // 使用数据创建适配器
        val adapter = LabListAdapter(items)

        // 设置点击监听器处理项目交互
        adapter.onItemClickListener = { item ->
            // 通过 MainActivity 的路由方法导航到选定的实验
            (requireActivity() as MainActivity).openLab(item.labId)
        }

        // 将适配器附加到 RecyclerView
        rv.adapter = adapter
    }
}
```

**关键概念**:
- 使用构造函数语法 `Fragment(R.layout.fragment_lab_list)` 进行布局填充
- `requireActivity()` 安全获取 Activity（如果为 null 则抛出异常）
- `requireContext()` 安全获取 Context（如果为 null 则抛出异常）
- 将导航逻辑委托给 MainActivity

#### 5. 实验列表适配器

**文件**: `app/src/main/java/com/nexa/perfstabilitylab/ui/home/LabListAdapter.kt`

```kotlin
package com.nexa.perfstabilitylab.ui.home

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.nexa.perfstabilitylab.R
import com.nexa.perfstabilitylab.core.LabItem

/**
 * RecyclerView 适配器，用于显示实验列表
 * 使用 ViewHolder 模式实现高效滚动
 */
class LabListAdapter(
    private val items: List<LabItem>
) : RecyclerView.Adapter<LabListAdapter.VH>() {

    // 点击监听器属性（可空，由 Fragment 设置）
    var onItemClickListener: ((LabItem) -> Unit)? = null

    /**
     * ViewHolder 保存项目视图的引用
     * 避免滚动时重复调用 findViewById
     */
    class VH(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val title: TextView = itemView.findViewById(R.id.tv_title)
        val desc: TextView = itemView.findViewById(R.id.tv_desc)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        // 填充项目布局（attachToRoot = false）
        val v = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_lab, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        // 获取当前位置的数据
        val item = items[position]

        // 将数据绑定到视图
        holder.title.text = item.title
        holder.desc.text = item.desc

        // 在整个项目视图上设置点击监听器
        holder.itemView.setOnClickListener {
            // 如果设置了回调则调用
            onItemClickListener?.invoke(item)
        }
    }

    override fun getItemCount(): Int = items.size
}
```

**RecyclerView 最佳实践**:
- ViewHolder 模式缓存视图引用
- LayoutInflater 中的 `attachToRoot = false`（RecyclerView 处理附加）
- 在 `onBindViewHolder` 中设置点击监听器以感知位置
- Lambda 回调实现简洁的事件处理

#### 6. 实验 Fragment 基类

**文件**: `app/src/main/java/com/nexa/perfstabilitylab/ui/lab/BaseLabFragment.kt`

```kotlin
package com.nexa.perfstabilitylab.ui.lab

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.google.android.material.chip.Chip
import com.nexa.perfstabilitylab.R
import com.nexa.perfstabilitylab.core.LabItem

/**
 * 所有实验 Fragment 的基类
 * 提供通用 UI 结构和数据绑定
 *
 * 子类只需提供 labItem 属性
 */
abstract class BaseLabFragment : Fragment() {

    // 子类必须重写此属性以提供其实验数据
    protected abstract val labItem: LabItem

    // 所有实验 Fragment 使用通用布局
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_lab, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // 显示实验标题和描述
        view.findViewById<android.widget.TextView>(R.id.tv_lab_title).text = labItem.title
        view.findViewById<android.widget.TextView>(R.id.tv_lab_desc).text = labItem.desc

        // 为每个标签创建 Chip
        val chipGroup = view.findViewById<com.google.android.material.chip.ChipGroup>(R.id.cg_tags)
        labItem.tags.forEach { tag ->
            val chip = Chip(requireContext()).apply {
                text = tag
                isClickable = false      // 标签仅用于显示，不可交互
                chipBackgroundColor = null  // 使用默认样式
            }
            chipGroup.addView(chip)
        }
    }
}
```

**模板方法模式**:
- 基类提供通用结构
- 子类只需重写 `labItem` 属性
- 减少了 6 个实验 Fragment 之间的代码重复

#### 7. 具体实验 Fragment

所有 6 个实验 Fragment 遵循相同的模式：

```kotlin
// StartupLabFragment.kt
package com.nexa.perfstabilitylab.ui.lab

import com.nexa.perfstabilitylab.core.LabId
import com.nexa.perfstabilitylab.core.LabItem
import com.nexa.perfstabilitylab.core.LabRegistry

/**
 * 启动优化实验页面
 */
class StartupLabFragment : BaseLabFragment() {
    // 通过 ID 从注册表获取实验数据
    override val labItem: LabItem get() = LabRegistry.getLabById(LabId.STARTUP)!!
}

// JankLabFragment.kt
class JankLabFragment : BaseLabFragment() {
    override val labItem: LabItem get() = LabRegistry.getLabById(LabId.JANK)!!
}

// LeakLabFragment.kt
class LeakLabFragment : BaseLabFragment() {
    override val labItem: LabItem get() = LabRegistry.getLabById(LabId.LEAK)!!
}

// OomLabFragment.kt
class OomLabFragment : BaseLabFragment() {
    override val labItem: LabItem get() = LabRegistry.getLabById(LabId.OOM)!!
}

// AnrLabFragment.kt
class AnrLabFragment : BaseLabFragment() {
    override val labItem: LabItem get() = LabRegistry.getLabById(LabId.ANR)!!
}

// CrashLabFragment.kt
class CrashLabFragment : BaseLabFragment() {
    override val labItem: LabItem get() = LabRegistry.getLabById(LabId.CRASH)!!
}
```

**DRY 原则**:
- 不要重复自己 - 基类处理所有通用逻辑
- 子类仅需约 10 行代码（导入和属性重写）
- 添加新实验非常简单：创建新 Fragment + 添加枚举值

#### 8. 实验 Fragment 布局

**文件**: `app/src/main/res/layout/fragment_lab.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp">

    <!-- 实验信息的卡片容器 -->
    <com.google.android.material.card.MaterialCardView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:cardElevation="4dp"
        app:cardUseCompatPadding="true">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="16dp">

            <!-- 实验标题 -->
            <TextView
                android:id="@+id/tv_lab_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="实验标题"
                android:textSize="20sp"
                android:textStyle="bold" />

            <!-- 实验描述 -->
            <TextView
                android:id="@+id/tv_lab_desc"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:text="实验描述"
                android:textSize="14sp" />

            <!-- 标签容器 -->
            <com.google.android.material.chip.ChipGroup
                android:id="@+id/cg_tags"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp" />

        </LinearLayout>

    </com.google.android.material.card.MaterialCardView>

    <!-- 实验内容的占位符 -->
    <!-- 未来几天将被实际的实验 UI 替换 -->
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="实验内容待实现..."
        android:textSize="16sp"
        android:textStyle="italic"
        android:textColor="@android:color/darker_gray" />

</LinearLayout>
```

---

## 导航流程

### 完整的用户旅程

```
1. 应用启动
   └─> MainActivity 创建 LabListFragment
   └─> Toolbar 显示 "PerfStabilityLab"（无返回箭头）

2. 用户点击 "卡顿 / Jank"
   └─> LabListFragment 调用 MainActivity.openLab(LabId.JANK)
   └─> MainActivity 创建 JankLabFragment
   └─> Fragment 添加到返回栈，名称为 "jank"
   └─> Toolbar 显示 "卡顿 / Jank"（返回箭头可见）

3. 用户点击返回箭头
   └─> 触发 onBackPressedDispatcher.onBackPressed()
   └─> JankLabFragment 从返回栈弹出
   └─> 返回到 LabListFragment
   └─> 触发 onBackStackChangedListener
   └─> updateNavigationIcon() 隐藏返回箭头
   └─> Toolbar 显示 "PerfStabilityLab"
```

### 返回栈管理

```kotlin
// 添加到返回栈
supportFragmentManager.beginTransaction()
    .replace(R.id.main_container, fragment)
    .addToBackStack(labId.id)  // "jank", "startup" 等
    .commit()

// 检查返回栈状态
val hasBackStack = supportFragmentManager.backStackEntryCount > 0
```

---

## 项目结构

```
app/src/main/java/com/nexa/perfstabilitylab/
├── MainActivity.kt                          # 单 Activity 与导航
├── core/
│   ├── LabId.kt                            # 实验 ID 枚举
│   ├── LabItem.kt                          # 实验数据模型
│   └── LabRegistry.kt                      # 中央实验注册表
├── ui/
│   ├── home/
│   │   ├── LabListFragment.kt             # 主列表屏幕
│   │   └── LabListAdapter.kt              # RecyclerView 适配器
│   └── lab/
│       ├── BaseLabFragment.kt             # 实验基类
│       ├── StartupLabFragment.kt          # 启动实验
│       ├── JankLabFragment.kt             # 卡顿实验
│       ├── LeakLabFragment.kt             # 内存泄漏实验
│       ├── OomLabFragment.kt              # OOM 实验
│       ├── AnrLabFragment.kt              # ANR 实验
│       └── CrashLabFragment.kt            # 崩溃实验
```

---

## 关键学习点

### Android 基础
1. **Fragment 导航**: 使用 `addToBackStack()` 实现正确的返回导航
2. **边到边显示**: 使用 `WindowInsetsCompat` 处理窗口 insets
3. **RecyclerView**: 始终使用 ViewHolder 模式以提高性能
4. **单例模式**: 使用 `object` 声明实现单例（如注册表）

### Kotlin 最佳实践
1. **数据类**: 用于模型，自动生成 `equals()`、`hashCode()`、`copy()`
2. **枚举类**: 提供比原始字符串更好的类型安全
3. **空安全**: 使用可空类型（`?`）和安全调用（`?.`）
4. **属性委托**: 通过自定义 getter 暴露计算属性

### 架构模式
1. **单 Activity**: 一个 Activity 托管多个 Fragment
2. **仓储模式**: 中央注册表管理数据访问
3. **模板方法**: 基类定义结构，子类自定义
4. **观察者模式**: 监听器回调处理用户交互

---

## 验收清单

### Day 1 交付物 ✅
- [x] 使用正确配置创建项目（minSdk 33）
- [x] 带有 MaterialToolbar 的 MainActivity
- [x] 用于托管 Fragment 的 FragmentContainerView
- [x] 正确处理 inset 的边到边显示
- [x] 导航按钮点击处理程序

### Day 2 交付物 ✅
- [x] 在 LabRegistry 中定义 6 个实验项
- [x] 带有 RecyclerView 的 LabListFragment
- [x] 带点击处理的 LabListAdapter
- [x] MainActivity.openLab() 路由方法
- [x] 用于导航图标控制的返回栈监听器
- [x] 6 个占位 LabFragment 实现
- [x] 导航：列表 → 实验 → 列表
- [x] 返回箭头正确显示/隐藏

### 手动测试步骤
1. 启动应用 → 应看到 6 个实验的列表
2. 点击任意实验 → 应导航到实验页面
3. 检查 Toolbar → 应显示实验标题和返回箭头
4. 点击返回箭头 → 应返回列表
5. 检查 Toolbar → 应显示 "PerfStabilityLab"，无箭头
6. 对所有 6 个实验重复测试

---

## 后续步骤（Day 3）

根据学习计划，Day 3 将重点：
- **统一模板**: 实验的复现/修复/验证按钮
- **屏幕日志**: 可滚动的 TextView 显示实验日志
- **文件日志**: 追加写入 `filesDir/perflab_records.jsonl`
- 将模板应用于所有 6 个实验 Fragment

这将建立"证据链"工作流程：
1. **复现**: 演示性能问题
2. **证据**: 捕获日志/trace/分析器数据
3. **修复**: 应用优化
4. **验证**: 通过新证据确认改进

---

## 代码质量说明

### 做得好的地方
- ✅ 关注点分离明确（core/ui/home/lab）
- ✅ 使用枚举实现类型安全导航
- ✅ 遵循 DRY 原则，使用基类 Fragment
- ✅ 正确的生命周期处理（requireContext、requireActivity）
- ✅ 现代 Android API（onBackPressedDispatcher、边到边）

### 未来改进方向
- 📝 考虑依赖注入管理 LabRegistry
- 📝 添加导航失败的错误处理
- 📝 实现视图绑定以实现类型安全的视图访问
- 📝 为 Fragment 过渡添加动画
- 📝 提取字符串到资源文件以支持国际化

---

## 总结

Day 1-2 成功建立了：
1. **项目基础**: 带 Fragment 导航的单 Activity 架构
2. **实验注册表**: 集中式、类型安全的实验管理
3. **导航系统**: 完整的路由和返回栈管理
4. **UI 框架**: RecyclerView 列表 + 详情 Fragment
5. **可扩展性**: 添加新实验只需最少的代码

项目现在已准备好实现 Day 3 的统一模板，包括日志记录和证据收集功能。
