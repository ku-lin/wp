---
title: "KMP算法_字符串匹配"
draft: false
---
- [一、问题背景](#%E4%B8%80%E9%97%AE%E9%A2%98%E8%83%8C%E6%99%AF)

---

## 一、问题背景

给定：

* 主串 `a`（text），长度 `n`
* 模式串 `b`（pattern），长度 `m`

判断 `b` 是否是 `a` 的子串，或返回首次出现的位置。

朴素匹配在最坏情况下时间复杂度为 **O(n·m)**，因为主串指针会反复回退。\
**KMP 的核心目标：避免主串指针回退。**

那我们检查一下b串，思考一下可不可能b串中间存在重复的字符，当检测到不对劲的时候可以跳过一段字符串重新计算，即在主串中不回退指针的情况下继续匹配

举个b串例子，ABHGABC

在这个b串的例子中，当我们一个个匹配到了第六个字符B的时候，发现第七个字符C不对，是重新开始匹配还是直接匹配第三个字符H呢？

发现我们可以直接匹配第三个字符H ，并不需要从头开始匹配，指针不回退，从而达到更快的速度

那么我们需要一个数组来记住当匹配发现问题的时候，我们可以回溯到第几个字符来重新匹配

就是说我们在匹配到一半的时候可以直接通过一个数来回到之前的位置，解决了重新匹配耗时间的问题

如何维护这个数组使得匹配到一半发现不对了的时候可以回溯

我们思考一下这个数组应该具备什么东西，即记录了当前字符为结尾字符串和从头开始的字符串有几个重合的字符

到了我们需要用的时候，我们可以直接跳转到开头的字符来进行匹配

需要注意的是有可能两个字符串有重合的部分，但是一定不能相等，相等对于计算结果没有作用

比如ABABC这个字符串，匹配HABABDABABC

当匹配到第一个D的时候，我们发现和C不一样，于是重新匹配，跳到了ABABC中间的第三个字符B再进行匹配，不需要退回去重新开始匹配，减少了大量时间

我们发现一个共性，即可以在记录信息的数组中自行递归直到回到0

好的，如何匹配已经解决，思考如何创建数组。

数组名叫LPS，中文名叫最长后缀前缀相同数组

放空大脑，直接双重循环解决。

```cpp
for(int i=1;i<b.length();i++){
    for(int j=0;j<b.length();j++){
        if(b[i+j] != b[j]){
            lps[i]=j+1;
            break;
        }
    }
}
```

好了，解决！

等等，发现一个问题，这个循环本质上也是一个一个匹配，那能不能嵌套一个刚才的思路。

比如说匹配到了第n个，发现第n+1个不对劲，那么直接返回到LPS\[n]就可以重新匹配

再思考一下，是不是匹配到n+1的时候LPS\[n]的所有是不是都已经做好了，发现确实是的

那么思路有了，直接一个个匹配，如果相等，那么直接匹配下一个

如果不相等，那么返回到LPS中的上一个n重新匹配，直到匹配到0

思路有了，接下来就是伪代码

```cpp
while i < b.len
    //i是匹配到第几个，len是相同的字符串的长度
    if b[i] == b[len]
        LPS[i]=len
        //记录一下LPS
        i++
        len++
        //直接匹配下一个
    else
        len=LPS[len]
        //一直匹配直到PLS[n]为0
```

```cpp
while i < a.len
    if a[i] == b[len]
        i++
        len++
        //直接++确保匹配下一个
    else
        len=LPS[len]
        //找到之前前缀相等的数重新匹配
        if len == 0
            i++
            //确定没有下一个可以匹配了，直接结束
```

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

// 构建模式串的LPS数组（最长前缀后缀数组）
vector<int> computeLPS(const string& pattern) {
    int m = pattern.size();
    vector<int> lps(m, 0);  // LPS数组初始化
    int len = 0;  // 当前最长前缀后缀的长度

    // 从第二个字符开始计算（i=0时LPS必为0）
    for (int i = 1; i < m; ) {
        if (pattern[i] == pattern[len]) {
            len++;
            lps[i] = len;
            i++;
        } else {
            if (len != 0) {
                // 回溯到上一个可能的最长前缀
                len = lps[len - 1];
            } else {
                // 无法匹配，LPS设为0
                lps[i] = 0;
                i++;
            }
        }
    }
    return lps;
}

// KMP匹配算法：返回模式串在主串中首次出现的起始索引，未找到返回-1
int kmpSearch(const string& text, const string& pattern, const vector<int>& lps) {
    int n = text.size();
    int m = pattern.size();
    int i = 0;  // 主串指针
    int j = 0;  // 模式串指针

    while (i < n) {
        if (text[i] == pattern[j]) {
            i++;
            j++;
        }

        // 匹配成功
        if (j == m) {
            return i - j;  // 返回起始索引
        }
        // 匹配失败
        else if (i < n && text[i] != pattern[j]) {
            if (j != 0) {
                // 利用LPS回溯模式串指针
                j = lps[j - 1];
            } else {
                // 模式串从头开始，主串后移
                i++;
            }
        }
    }
    // 未找到匹配
    return -1;
}

int main() {
    string text = "ABABABC";    // 主串
    string pattern = "ABABC";   // 模式串

    // 构建LPS数组
    vector<int> lps = computeLPS(pattern);

    // 执行KMP匹配
    int result = kmpSearch(text, pattern, lps);

    if (result != -1) {
        cout << "模式串在主串中首次出现的位置：" << result << endl;
    } else {
        cout << "主串中未找到模式串" << endl;
    }

    // 打印LPS数组（可选）
    cout << "模式串的LPS数组：";
    for (int val : lps) {
        cout << val << " ";
    }
    cout << endl;

    return 0;
}
```

