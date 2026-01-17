---
title: Android-Day02-RecycleView&路由跳转
date: 2026-1-16 01:00:00
categories: Android
hide: true
---

Day2 目标很明确：把“首页实验列表（RecyclerView）→ 点击进入实验页（Fragment）→ 返回回列表”这条最小导航链路跑通。你只需要做到“能跳转、能返回、Toolbar 返回箭头逻辑正确”，不需要做任何性能实验内容。
<!--more-->
# 按产出拆成 4 件事

### 首页：RecyclerView 显示实验入口列表

- 做一个 LabItem 数据结构（id、标题、简介、tags 可先不做或先留空）
- LabListFragment 展示一个 RecyclerView 列表（至少 6 项占位）：
    - 启动优化
    - 卡顿/Jank
    - 泄漏
    - OOM
    - ANR
    - Crash

### 路由：点击列表项能进入对应 LabFragment

- 做一个 LabRegistry（注册表）：
    - all() 返回上述 6 个 LabItem
    - createFragment(id) 返回对应的 Fragment（先是空页面/占位页面也可以）

### Activity：负责切换 Fragment + back stack

- MainActivity.openLab(id)：
    - replace(R.id.main_container, LabRegistry.createFragment(id))
    - addToBackStack(id)

### Toolbar：返回箭头显示/隐藏（Day2 的“完成标志”）

- 在列表页：Toolbar 不显示返回箭头
- 进入实验页：Toolbar 显示返回箭头，点击能返回列表
- 实现方式：监听 supportFragmentManager.addOnBackStackChangedListener { ... }，根据 backStack 是否为空来决定 supportActionBar?.setDisplayHomeAsUpEnabled(...)

# RecyclerView 显示实验入口列表

### 新建数据结构：LabItem

新建 app/src/main/java/com/nexa/perfstabilitylab/core/LabItem.kt
```
package com.nexa.perfstabilitylab.core

data class LabItem(
    val id: String,
    val title: String,
    val desc: String
)
```


### 新建列表页布局：fragment_lab_list.xml

新建 app/src/main/res/layout/fragment_lab_list.xml
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.recyclerview.widget.RecyclerView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/rv_labs"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp"
    android:clipToPadding="false"/>
```


### 新建列表 item 布局：item_lab.xml

新建 app/src/main/res/layout/item_lab.xml
```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:paddingVertical="12dp">

    <TextView
        android:id="@+id/tv_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textSize="16sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/tv_desc"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:textSize="13sp"
        android:alpha="0.75" />

</LinearLayout>
```


### 新建 Adapter：LabListAdapter

新建 app/src/main/java/com/nexa/perfstabilitylab/ui/home/LabListAdapter.kt
```
package com.nexa.perfstabilitylab.ui.home

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.nexa.perfstabilitylab.R
import com.nexa.perfstabilitylab.core.LabItem

class LabListAdapter(
    private val items: List<LabItem>
) : RecyclerView.Adapter<LabListAdapter.VH>() {

    class VH(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val title: TextView = itemView.findViewById(R.id.tv_title)
        val desc: TextView = itemView.findViewById(R.id.tv_desc)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_lab, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = items[position]
        holder.title.text = item.title
        holder.desc.text = item.desc
    }

    override fun getItemCount(): Int = items.size
}
```


### 新建 Fragment：LabListFragment

新建 app/src/main/java/com/nexa/perfstabilitylab/ui/home/LabListFragment.kt
```
package com.nexa.perfstabilitylab.ui.home

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.nexa.perfstabilitylab.R
import com.nexa.perfstabilitylab.core.LabItem

class LabListFragment : Fragment(R.layout.fragment_lab_list) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val rv = view.findViewById<RecyclerView>(R.id.rv_labs)
        rv.layoutManager = LinearLayoutManager(requireContext())

        val items = listOf(
            LabItem("startup", "启动优化", "冷/温/热启动、初始化治理、首帧直觉"),
            LabItem("jank", "卡顿 / Jank", "主线程阻塞、IO、锁等待、UI/GC"),
            LabItem("leak", "内存泄漏", "引用链、生命周期注销"),
            LabItem("oom", "OOM", "峰值、Bitmap、缓存上限、降级"),
            LabItem("anr", "ANR", "无响应、主线程卡死/等待"),
            LabItem("crash", "Crash", "栈+上下文、定位与闭环")
        )

        rv.adapter = LabListAdapter(items)
    }
}
```

### MainActivity 启动时显示这个列表 Fragment

在 MainActivity.onCreate() 里（setContentView 之后）：
```
if (savedInstanceState == null) {
    supportFragmentManager.beginTransaction()
        .replace(R.id.main_container, LabListFragment())
        .commit()
}
```
———

## Step1 完成验收

- App 启动后看到 6 条实验入口列表。
![](/images/android/Day02-recyclerview_router/01.png)

