---
title: DSA-Day03-347.前K个高频元素
date: 2026-1-18 00:00:00
categories: 数据结构与算法
---

## 题目概述
**Top K 问题的经典应用**。本题是 LeetCode 中等难度题，核心考点是**在 O(n) 时间复杂度内找出前 k 个高频元素**，是 Google、Meta 等大厂面试高频题。

## 为什么这道题重要
这是 **Top K 问题**的典范，掌握后可举一反三解决：
- [215. 第 K 个最大元素](https://leetcode.cn/problems/kth-largest-element-in-an-array/)
- [692. 前 K 个高频单词](https://leetcode.cn/problems/top-k-frequent-words/)
- [347. 前K个高频元素](https://leetcode.cn/problems/top-k-frequent-elements/)（本题）

关键不在统计频率（HashMap 基础操作），而在如何**高效地选出 Top K**。进阶要求时间复杂度必须优于 O(n log n)，这迫使你必须使用**桶排序**。

## 解法对比
| 解法 | 时间复杂度 | 空间复杂度 | 说明 |
|------|-----------|-----------|------|
| 哈希表 + 排序 | O(n log n) | O(n) | 基础解法 |
| 哈希表 + 小顶堆 | O(n log k) | O(n) | k << n 时较优 |
| **哈希表 + 桶排序** | **O(n)** | O(n) | **最优解，推荐背诵** |

**背诵重点**：桶排序解法（满足进阶要求 O(n)）

<!--more-->

## 题目
![](/images/algos/Day03-Top-K-Frequent/01.png)

## 标签
数组、哈希表、分治、桶排序、计数、快速选择、排序、堆（优先队列）

## 背诵模型
**模型/状态**

+ 我用一个**HashMap**统计每个元素的出现频率，再用一个**桶数组**（索引为频率，值为元素列表）存储

**不变量/约束**

+ 遍历HashMap到当前元素，桶数组中满足：
    - 索引 i 的桶中存储所有出现频率为 i 的元素
    - 频率范围是 [1, n]，因此创建 n+1 个桶
    - 桶是按频率天然有序的（索引越大，频率越高）

**推进/转移**

+ 对于每个(元素, 频率)对：
    - 直接放入对应频率索引的桶中：buckets[freq].add(num)

**终止/答案+边界**

+ 终止：
    - 从高频率桶（索引 n）向低频率桶（索引 1）遍历
    - 收集元素直到凑够 k 个
+ 边界：
    - k=1：只返回频率最高的1个元素
    - 所有元素频率都不同：题目保证答案唯一
    - k等于元素种类数：返回所有元素

**复杂度**

+ 时间复杂度：O(n)，其中 n 是数组长度。统计频率需要 O(n)，创建桶并填充需要 O(n)，从高到低遍历桶最坏需要 O(n)，因此总时间复杂度是 O(n)。满足进阶要求（优于 O(n log n)）。

+ 空间复杂度：O(n)，其中 n 是数组长度。哈希表最坏需要存储 O(n) 个键值对，桶数组需要 O(n) 空间。

**常见坑**

+ 桶的大小必须是 n+1（频率范围是 1 到 n）
+ 从高频率向低频率遍历，不要反了
- 使用 `downTo` 而不是 `until` 进行倒序遍历
- 收集结果时注意判断 `result.size >= k`，避免数组越界




## 代码

### kotlin - 桶排序解法（O(n) 最优解）
```plain
class Solution {
    fun topKFrequent(nums: IntArray, k: Int): IntArray {
        // 1. 统计频率
        val freqMap = HashMap<Int, Int>()
        for (num in nums) {
            freqMap[num] = freqMap.getOrDefault(num, 0) + 1
        }

        // 2. 创建桶（索引为频率，值为元素列表）
        val n = nums.size
        val buckets = Array<MutableList<Int>>(n + 1) { mutableListOf() }

        for ((num, freq) in freqMap) {
            buckets[freq].add(num)
        }

        // 3. 从高频率向低频率遍历
        val result = mutableListOf<Int>()
        for (i in n downTo 1) {
            result.addAll(buckets[i])
            if (result.size >= k) {
                return result.take(k).toIntArray()
            }
        }

        return result.toIntArray()
    }
}
```

### java - 桶排序解法（O(n) 最优解）
```plain
import java.util.*;

class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        // 1. 统计频率
        Map<Integer, Integer> freqMap = new HashMap<>();
        for (int num : nums) {
            freqMap.put(num, freqMap.getOrDefault(num, 0) + 1);
        }

        // 2. 创建桶（索引为频率，值为元素列表）
        int n = nums.length;
        List<Integer>[] buckets = new List[n + 1];
        for (int i = 0; i <= n; i++) {
            buckets[i] = new ArrayList<>();
        }

        for (Map.Entry<Integer, Integer> entry : freqMap.entrySet()) {
            int num = entry.getKey();
            int freq = entry.getValue();
            buckets[freq].add(num);
        }

        // 3. 从高频率向低频率遍历
        List<Integer> result = new ArrayList<>();
        for (int i = n; i >= 1; i--) {
            result.addAll(buckets[i]);
            if (result.size() >= k) {
                break;
            }
        }

        // 转换为数组
        int[] ans = new int[k];
        for (int i = 0; i < k; i++) {
            ans[i] = result.get(i);
        }
        return ans;
    }
}
```
