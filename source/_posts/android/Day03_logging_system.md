---
title: Android-Day03-实验框架与日志系统
date: 2026-1-18 14:30:00
categories: Android
hide: false
---

Day3 目标：搭建实验页面的通用框架。所有实验都共用一套 UI 结构（标题+简介+tags+三个操作按钮+日志显示区），只是每个实验的"复现/修复/验证"逻辑不同。因此需要抽一个 BaseLabFragment 基类，提供统一的布局、日志系统（显示/清空/保存），子类只需实现三个按钮的点击逻辑即可。
<!--more-->

# 按产出拆成 3 件事

### 实验基类：BaseLabFragment

- 抽象基类，提供统一的实验页面结构
- 抽象属性 `labItem`：子类必须提供
- 三个 open 方法：`onReproduce()`、`onFix()`、`onVerify()`，子类覆盖实现具体逻辑
- 日志系统：`log()` 方法记录日志，显示在页面上

### 实验页面布局：fragment_lab.xml

- 顶部：标题、描述、tags（ChipGroup）
- 中部：三个操作按钮（复现、修复、验证）
- 底部：日志显示区（TextView + ScrollView）+ 清空/保存按钮
- 使用 layout_weight 让日志区自适应高度

### 子类实现：StartupLabFragment

- 继承 BaseLabFragment
- 提供 labItem（从 LabRegistry 获取）
- 实现 onReproduce/onFix/onVerify 三个方法
- 每个方法里调用 log() 记录操作日志

# 新建实验基类：BaseLabFragment

新建 app/src/main/java/com/nexa/perfstabilitylab/ui/lab/BaseLabFragment.kt

```
package com.nexa.perfstabilitylab.ui.lab

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.google.android.material.chip.Chip
import com.google.android.material.chip.ChipGroup
import com.nexa.perfstabilitylab.R
import com.nexa.perfstabilitylab.core.LabItem
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

abstract class BaseLabFragment : Fragment(R.layout.fragment_lab) {

    // 抽象属性：子类必须提供
    protected abstract val labItem: LabItem

    private lateinit var tvLog: TextView
    private val logEntries = mutableListOf<String>()
    private val logDateFormat = SimpleDateFormat("HH:mm:ss.SSS", Locale.getDefault())

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // 显示标题和描述
        view.findViewById<TextView>(R.id.tv_title).text = labItem.title
        view.findViewById<TextView>(R.id.tv_desc).text = labItem.desc

        // 动态添加 tags
        val chipGroup = view.findViewById<ChipGroup>(R.id.cg_tags)
        labItem.tags.forEach { tag ->
            val chip = Chip(requireContext()).apply {
                text = tag
                isClickable = false
            }
            chipGroup.addView(chip)
        }

        // 日志相关
        tvLog = view.findViewById(R.id.tv_log)
        view.findViewById<Button>(R.id.btn_clear_log).setOnClickListener {
            logEntries.clear()
            updateLogDisplay()
        }
        view.findViewById<Button>(R.id.btn_save_log).setOnClickListener { saveLog() }

        // 三个操作按钮
        view.findViewById<Button>(R.id.btn_reproduce).setOnClickListener { onReproduce() }
        view.findViewById<Button>(R.id.btn_fix).setOnClickListener { onFix() }
        view.findViewById<Button>(R.id.btn_verify).setOnClickListener { onVerify() }
    }

    // 子类覆盖实现具体逻辑
    protected open fun onReproduce() {}
    protected open fun onFix() {}
    protected open fun onVerify() {}

    // 日志系统
    protected fun log(message: String, tag: String = "INFO") {
        val timestamp = logDateFormat.format(Date())
        val entry = "[$timestamp] [$tag] $message"
        logEntries.add(entry)
        updateLogDisplay()
    }

    private fun updateLogDisplay() {
        tvLog.text = if (logEntries.isEmpty()) {
            "等待操作"
        } else {
            logEntries.joinToString("\n")
        }
        // 自动滚动到底部
        tvLog.post {
            (tvLog.parent as? ScrollView)?.fullScroll(View.FOCUS_DOWN)
        }
    }

    private fun saveLog() {
        if (logEntries.isEmpty()) {
            Toast.makeText(requireContext(), "没有日志可保存", Toast.LENGTH_SHORT).show()
            return
        }

        try {
            val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val fileName = "Lab_${labItem.id}_$timestamp.log"
            val file = File(requireContext().filesDir, fileName)
            file.writeText(logEntries.joinToString("\n"))

            log("日志已保存: ${file.absolutePath}", "SYSTEM")
            Toast.makeText(requireContext(), "日志已保存\n${file.absolutePath}", Toast.LENGTH_LONG).show()
        } catch (e: Exception) {
            log("保存日志失败: ${e.message}", "ERROR")
            Toast.makeText(requireContext(), "保存失败: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}
```

# 新建实验页面布局：fragment_lab.xml

新建 app/src/main/res/layout/fragment_lab.xml

```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp">

    <!-- 标题和描述 -->
    <TextView
        android:id="@+id/tv_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textSize="20sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/tv_desc"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:textSize="14sp"
        android:alpha="0.75" />

    <!-- Tags -->
    <com.google.android.material.chip.ChipGroup
        android:id="@+id/cg_tags"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp" />

    <!-- 分隔线 -->
    <View
        android:layout_width="match_parent"
        android:layout_height="1dp"
        android:layout_marginVertical="12dp"
        android:alpha="0.12"
        android:background="?android:attr/colorForeground" />

    <!-- 操作按钮 -->
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="实验操作"
        android:textSize="14sp"
        android:textStyle="bold" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:orientation="horizontal">

        <Button
            android:id="@+id/btn_reproduce"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:layout_marginEnd="4dp"
            android:text="复现" />

        <Button
            android:id="@+id/btn_fix"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:layout_marginStart="4dp"
            android:layout_marginEnd="4dp"
            android:text="修复" />

        <Button
            android:id="@+id/btn_verify"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:layout_marginStart="4dp"
            android:text="验证" />

    </LinearLayout>

    <!-- 日志区域 -->
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="运行日志"
        android:textSize="14sp"
        android:textStyle="bold" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:orientation="horizontal"
        android:gravity="end">

        <Button
            android:id="@+id/btn_clear_log"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="清空" />

        <Button
            android:id="@+id/btn_save_log"
            style="@style/Widget.Material3.Button.TextButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="保存" />

    </LinearLayout>

    <ScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:layout_marginTop="8dp"
        android:background="@android:color/black"
        android:padding="8dp">

        <TextView
            android:id="@+id/tv_log"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:fontFamily="monospace"
            android:textColor="@android:color/white"
            android:textSize="12sp"
            android:text="等待操作" />

    </ScrollView>

</LinearLayout>
```

# 新建启动优化实验：StartupLabFragment

新建 app/src/main/java/com/nexa/perfstabilitylab/ui/lab/StartupLabFragment.kt

```
package com.nexa.perfstabilitylab.ui.lab

import com.nexa.perfstabilitylab.core.LabRegistry

class StartupLabFragment : BaseLabFragment() {
    override val labItem get() = LabRegistry.getLabById("startup")!!

    override fun onReproduce() {
        log("=== 开始复现启动问题 ===", "REPRODUCE")
        log("模拟冷启动耗时操作...")
        log("主线程执行 2000ms 耗时任务", "TIMING")
        log("应用启动时间: 3500ms", "RESULT")
        log("检测到启动超时问题", "ISSUE")
    }

    override fun onFix() {
        log("=== 应用优化方案 ===", "FIX")
        log("1. 移除 Application 中的耗时初始化")
        log("2. 使用懒加载延迟非关键组件")
        log("3. 首帧渲染优化")
        log("优化完成", "SUCCESS")
    }

    override fun onVerify() {
        log("=== 验证优化效果 ===", "VERIFY")
        log("重新测试启动性能...")
        log("应用启动时间: 1200ms", "RESULT")
        log("性能提升 65%", "SUCCESS")
        log("优化验证通过 ✓", "PASS")
    }
}
```

# 更新 LabRegistry

修改 LabRegistry.kt，让 LabItem 支持 tags 字段：

```
data class LabItem(
    val id: String,
    val title: String,
    val desc: String,
    val tags: List<String> = emptyList()
)
```

更新 LabRegistry.all()：

```
fun all(): List<LabItem> = listOf(
    LabItem("startup", "启动优化", "冷/温/热启动、初始化治理、首帧直觉", listOf("启动", "性能")),
    LabItem("jank", "卡顿 / Jank", "主线程阻塞、IO、锁等待、UI/GC", listOf("卡顿", "性能")),
    LabItem("leak", "内存泄漏", "引用链、生命周期注销", listOf("内存")),
    LabItem("oom", "OOM", "峰值、Bitmap、缓存上限、降级", listOf("内存", "优化")),
    LabItem("anr", "ANR", "无响应、主线程卡死/等待", listOf("ANR")),
    LabItem("crash", "Crash", "栈+上下文、定位与闭环", listOf("稳定性"))
)
```

更新 LabRegistry.createFragment()：

```
fun createFragment(id: String): Fragment {
    return when (id) {
        "startup" -> StartupLabFragment()
        // 其他实验暂时返回空 Fragment
        else -> Fragment(R.layout.fragment_empty)
    }
}
```

# Day3 完成验收

- 进入"启动优化"实验页，看到标题、描述、tags 显示正确
- 点击"复现"按钮，日志区显示操作日志
- 点击"修复"按钮，日志区继续追加日志
- 点击"验证"按钮，日志区继续追加日志
- 点击"清空"按钮，日志被清空
- 点击"保存"按钮，Toast 提示保存成功
- 日志自动滚动到底部
![](/images/android/Day03_logging_system/01.png)
