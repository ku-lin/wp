---
title: "python"
draft: false
---
- [正则表达式](#%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F)
  * [一、正则表达式核心语法（模式规则）](#%E4%B8%80%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F%E6%A0%B8%E5%BF%83%E8%AF%AD%E6%B3%95%E6%A8%A1%E5%BC%8F%E8%A7%84%E5%88%99)
    + [1. 基础匹配（匹配固定字符 / 位置）](#1-%E5%9F%BA%E7%A1%80%E5%8C%B9%E9%85%8D%E5%8C%B9%E9%85%8D%E5%9B%BA%E5%AE%9A%E5%AD%97%E7%AC%A6--%E4%BD%8D%E7%BD%AE)
    + [2. 量词（控制前面元素的匹配次数）](#2-%E9%87%8F%E8%AF%8D%E6%8E%A7%E5%88%B6%E5%89%8D%E9%9D%A2%E5%85%83%E7%B4%A0%E7%9A%84%E5%8C%B9%E9%85%8D%E6%AC%A1%E6%95%B0)
    + [3. 字符集与分组](#3-%E5%AD%97%E7%AC%A6%E9%9B%86%E4%B8%8E%E5%88%86%E7%BB%84)
    + [4. 断言（零宽匹配，只判断位置，不消耗字符）](#4-%E6%96%AD%E8%A8%80%E9%9B%B6%E5%AE%BD%E5%8C%B9%E9%85%8D%E5%8F%AA%E5%88%A4%E6%96%AD%E4%BD%8D%E7%BD%AE%E4%B8%8D%E6%B6%88%E8%80%97%E5%AD%97%E7%AC%A6)
  * [二、Python `re` 模块常用函数](#%E4%BA%8Cpython-re-%E6%A8%A1%E5%9D%97%E5%B8%B8%E7%94%A8%E5%87%BD%E6%95%B0)
    + [1. 匹配与搜索（判断是否存在匹配）](#1-%E5%8C%B9%E9%85%8D%E4%B8%8E%E6%90%9C%E7%B4%A2%E5%88%A4%E6%96%AD%E6%98%AF%E5%90%A6%E5%AD%98%E5%9C%A8%E5%8C%B9%E9%85%8D)
      - [关键：匹配对象（`Match` 对象）的用法](#%E5%85%B3%E9%94%AE%E5%8C%B9%E9%85%8D%E5%AF%B9%E8%B1%A1match-%E5%AF%B9%E8%B1%A1%E7%9A%84%E7%94%A8%E6%B3%95)
    + [2. 替换与分割（修改字符串）](#2-%E6%9B%BF%E6%8D%A2%E4%B8%8E%E5%88%86%E5%89%B2%E4%BF%AE%E6%94%B9%E5%AD%97%E7%AC%A6%E4%B8%B2)
    + [3. 编译正则（优化重复使用场景）](#3-%E7%BC%96%E8%AF%91%E6%AD%A3%E5%88%99%E4%BC%98%E5%8C%96%E9%87%8D%E5%A4%8D%E4%BD%BF%E7%94%A8%E5%9C%BA%E6%99%AF)
    + [4. 常用修饰符（`flags` 参数）](#4-%E5%B8%B8%E7%94%A8%E4%BF%AE%E9%A5%B0%E7%AC%A6flags-%E5%8F%82%E6%95%B0)
- [特殊语法](#%E7%89%B9%E6%AE%8A%E8%AF%AD%E6%B3%95)
  * [复数](#%E5%A4%8D%E6%95%B0)
  * [字符串拼接](#%E5%AD%97%E7%AC%A6%E4%B8%B2%E6%8B%BC%E6%8E%A5)
  * [字符串引用](#%E5%AD%97%E7%AC%A6%E4%B8%B2%E5%BC%95%E7%94%A8)
    + [1.使用f快速格式化](#1%E4%BD%BF%E7%94%A8f%E5%BF%AB%E9%80%9F%E6%A0%BC%E5%BC%8F%E5%8C%96)
    + [2.使用%s方式](#2%E4%BD%BF%E7%94%A8%25s%E6%96%B9%E5%BC%8F)
    + [3.使用format](#3%E4%BD%BF%E7%94%A8format)
  * [运算符](#%E8%BF%90%E7%AE%97%E7%AC%A6)
  * [列表推导式](#%E5%88%97%E8%A1%A8%E6%8E%A8%E5%AF%BC%E5%BC%8F)
  * [函数](#%E5%87%BD%E6%95%B0)
    + [位置参数：](#%E4%BD%8D%E7%BD%AE%E5%8F%82%E6%95%B0)
    + [默认参数：](#%E9%BB%98%E8%AE%A4%E5%8F%82%E6%95%B0)
    + [关键字参数：](#%E5%85%B3%E9%94%AE%E5%AD%97%E5%8F%82%E6%95%B0)
    + [可变长参数：](#%E5%8F%AF%E5%8F%98%E9%95%BF%E5%8F%82%E6%95%B0)
    + [缺省参数](#%E7%BC%BA%E7%9C%81%E5%8F%82%E6%95%B0)
    + [注意事项](#%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9)
- [数据类型](#%E6%95%B0%E6%8D%AE%E7%B1%BB%E5%9E%8B)
  * [list（列表）](#list%E5%88%97%E8%A1%A8)
    + [list.append(obj)](#listappendobj)
    + [list.index(value, start=0, end=len(list))](#listindexvalue-start0-endlenlist)
    + [list.insert(index, obj)](#listinsertindex-obj)
    + [list.extend(iterable)](#listextenditerable)
    + [list.pop(index=-1)](#listpopindex-1)
    + [list.count(value)](#listcountvalue)
    + [list.sort(key=None, reverse=False)](#listsortkeynone-reversefalse)
    + [list.copy()](#listcopy)
  * [dict（字典）](#dict%E5%AD%97%E5%85%B8)
    + [dict.get(key, default=None)](#dictgetkey-defaultnone)
    + [dict.setdefault(key, default=None)](#dictsetdefaultkey-defaultnone)
    + [dict.update(other)](#dictupdateother)
    + [dict.pop(key, default=None)](#dictpopkey-defaultnone)
    + [dict.popitem()](#dictpopitem)
    + [dict.clear()](#dictclear)
    + [dict.keys()](#dictkeys)
    + [dict.values()](#dictvalues)
    + [dict.items()](#dictitems)
  * [set（集合）](#set%E9%9B%86%E5%90%88)
    + [set.add(element)](#setaddelement)
    + [set.remove(element)](#setremoveelement)
    + [set.discard(element)](#setdiscardelement)
    + [set.pop()](#setpop)
    + [set.clear()](#setclear)
  * [tuple（元组）](#tuple%E5%85%83%E7%BB%84)
    + [tuple.count(value)](#tuplecountvalue)
    + [tuple.index(value, start=0, end=len(tuple))](#tupleindexvalue-start0-endlentuple)
    + [tuple()](#tuple)
  * [str（字符串）](#str%E5%AD%97%E7%AC%A6%E4%B8%B2)
    + [str.find(sub, start=0, end=len(str))](#strfindsub-start0-endlenstr)
    + [str.rfind(sub, start=0, end=len(str))](#strrfindsub-start0-endlenstr)
    + [str.split(sep=None, maxsplit=-1)](#strsplitsepnone-maxsplit-1)
    + [str.join(iterable)](#strjoiniterable)
    + [str.capitalize()](#strcapitalize)
    + [str.swapcase()](#strswapcase)
    + [str.title()](#strtitle)
    + [str.strip(chars=None)](#strstripcharsnone)
    + [str.partition(sep)](#strpartitionsep)
- [函数使用方法](#%E5%87%BD%E6%95%B0%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95)
  * [自带函数](#%E8%87%AA%E5%B8%A6%E5%87%BD%E6%95%B0)
    + [import](#import)
    + [id(A)](#ida)
    + [type(A)](#typea)
    + [ord(A)](#orda)
    + [print (\*objects, sep=' ', end='\n', file=sys.stdout, flush=False)](#print-objects-sep--endn-filesysstdout-flushfalse)
    + [reversed(seq)](#reversedseq)
    + [round(number, ndigits=None)](#roundnumber-ndigitsnone)
    + [min(iterable, \*\[, key, default])](#miniterable--key-default)
    + [max(iterable, \*\[, key, default])](#maxiterable--key-default)
    + [divmod(a, b)](#divmoda-b)
    + [pow(base, exp, mod=None)](#powbase-exp-modnone)
    + [enumerate(iterable, start=0)](#enumerateiterable-start0)
    + [map(function, iterable, ...)](#mapfunction-iterable-)
    + [open(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True, opener=None) as file:](#openfile-moder-buffering-1-encodingnone-errorsnone-newlinenone-closefdtrue-openernone-as-file)
    + [![1767834856994-ba19ea74-36ce-445b-8ca1-31cd7ea32073.png](./img/N9PuQgqwmMlFhUkL/1767834856994-ba19ea74-36ce-445b-8ca1-31cd7ea32073-250098.png)](#1767834856994-ba19ea74-36ce-445b-8ca1-31cd7ea32073pngimgn9puqgqwmmlfhukl1767834856994-ba19ea74-36ce-445b-8ca1-31cd7ea32073-250098png)
  * [fractions](#fractions)
    + [fractions.fraction(A, B)](#fractionsfractiona-b)
  * [decimal](#decimal)
    + [decimal.Decimal(A)](#decimaldecimala)
  * [random](#random)
    + [random.uniform(a, b)](#randomuniforma-b)
    + [random.randint(a, b)](#randomrandinta-b)
    + [random.randrange(start, stop=None, step=1)](#randomrandrangestart-stopnone-step1)
    + [random.choice(seq)](#randomchoiceseq)
    + [random.sample(population, k)](#randomsamplepopulation-k)
    + [random.shuffle(x)](#randomshufflex)
  * [copy](#copy)
    + [copy.deepcopy(x)](#copydeepcopyx)
  * [math](#math)
    + [math.ceil(x)](#mathceilx)
    + [math.sqrt(x)](#mathsqrtx)
  * [OS](#os)
    + [os.getcwd()](#osgetcwd)
    + [os.chdir(path)](#oschdirpath)
    + [os.path.exists(path)](#ospathexistspath)
    + [os.path.isdir(path)](#ospathisdirpath)
    + [os.path.isfile(path)](#ospathisfilepath)
    + [os.listdir(path='.')](#oslistdirpath)
    + [os.mkdir(dir\_path)](#osmkdirdir_path)
    + [os.remove(file\_path)](#osremovefile_path)

---

# 正则表达式

## <font style="color:rgb(0, 0, 0);">一、正则表达式核心语法（模式规则）</font>

正则语法是「匹配规则的约定」，常用元素按功能分类如下，重点记高频用法：

### <font style="color:rgb(0, 0, 0);">1. 基础匹配（匹配固定字符 / 位置）</font>

| **语法** | **说明** | **示例** |
| :--- | :--- | :--- |
| 普通字符 | 匹配自身（字母、数字、符号等） | `abc`<br/> 匹配 "abc"，`123`<br/> 匹配 "123" |
| `.` | 匹配任意单个字符（除换行 `\n`<br/>） | `a.b`<br/> 匹配 "aab"、"acb"、"a1b" |
| `^` | 匹配字符串**开头**（多行模式下匹配行首） | `^Hello`<br/> 匹配 "HelloWorld" 开头 |
| `$` | 匹配字符串**结尾**（多行模式下匹配行尾） | `World$`<br/> 匹配 "HelloWorld" 结尾 |
| `\b` | 单词边界（字母与非字母的交界处） | `\bi\b`<br/> 匹配单独的 "i"（如 "i"） |
| `\B` | 非单词边界（字母与字母 / 非字母与非字母交界处） | `\Bi\B`<br/> 匹配单词内部的 "i"（如 "appreciatei" 中的 i） |
| `\d` | 匹配数字（等价于 `[0-9]`<br/>） | `\d{3}`<br/> 匹配 "123"、"456" |
| `\D` | 匹配非数字（等价于 `[^0-9]`<br/>） | `\D`<br/> 匹配 "a"、"!"、" " |
| `\w` | 匹配字母 / 数字 / 下划线（等价于 `[a-zA-Z0-9_]`<br/>） | `\w+`<br/> 匹配 "name123"、"user\_name" |
| `\W` | 匹配非字母 / 数字 / 下划线（如标点、空格） | `\W`<br/> 匹配 "!"、"，"、" " |
| `\s` | 匹配空白字符（空格、制表符 `\t`<br/>、换行 `\n`<br/> 等） | `a\sb`<br/> 匹配 "a b"、"a\tb" |
| `\S` | 匹配非空白字符 | `\S+`<br/> 匹配 "abc"、"123!" |

### <font style="color:rgb(0, 0, 0);">2. 量词（控制前面元素的匹配次数）</font>

| **语法** | **说明** | **示例** |
| :--- | :--- | :--- |
| `*` | 匹配前面元素 0 次或多次（贪婪：尽可能多匹配） | `ab*`<br/> 匹配 "a"、"ab"、"abb" |
| `+` | 匹配前面元素 1 次或多次（贪婪） | `ab+`<br/> 匹配 "ab"、"abb"（不匹配 "a"） |
| `?` | 匹配前面元素 0 次或 1 次（贪婪） | `ab?`<br/> 匹配 "a"、"ab"（不匹配 "abb"） |
| `{n}` | 匹配前面元素**恰好 n 次** | `a{3}`<br/> 匹配 "aaa"（不匹配 "aa"） |
| `{n,}` | 匹配前面元素**至少 n 次**（贪婪） | `a{2,}`<br/> 匹配 "aa"、"aaa"、"aaaa" |
| `{n,m}` | 匹配前面元素**n 到 m 次**（贪婪） | `a{1,3}`<br/> 匹配 "a"、"aa"、"aaa" |
| `*?`<br/>/`+?`<br/>/`??` | 非贪婪匹配（尽可能少匹配） | `a.*?b`<br/> 匹配 "aab" 中的 "aab"（而非贪婪的 "aab..."） |

### <font style="color:rgb(0, 0, 0);">3. 字符集与分组</font>

| **语法** | **说明** | **示例** | | |
| :--- | :--- | :--- | --- | --- |
| `[abc]` | 匹配括号内任意一个字符（等价于 `a | b | c`） | `[abc]`<br/> 匹配 "a"、"b"、"c" |
| `[^abc]` | 匹配括号外任意一个字符（取反） | `[^abc]`<br/> 匹配 "d"、"1"、"!" | | |
| `[a-z]` | 匹配小写字母（连续字符范围，需按 ASCII 顺序） | `[a-z]`<br/> 匹配 "a" 到 "z" | | |
| `[A-Z0-9]` | 匹配大写字母或数字（多范围组合） | `[A-Z0-9]`<br/> 匹配 "A"、"5"、"Z" | | |
| `(abc)` | 分组（将多个字符视为一个整体，可用于提取 / 替换） | `(ab)+`<br/> 匹配 "ab"、"abab" | | |
| `a | b` | 逻辑或（匹配 a 或 b，优先级低，需用分组包裹） | `(ab) | (cd)`匹配"ab"或"cd" |
| `\1`<br/>/`\2` | 反向引用（引用第 n 个分组的匹配结果） | `(a)\1`<br/> 匹配 "aa"，`(a)(b)\2\1`<br/> 匹配 "abba" | | |
| `(?P<name>...)` | 命名分组（给分组起名字，便于后续提取） | `(?P<year>\d{4})`<br/> 匹配年份并命名为 "year" | | |

### <font style="color:rgb(0, 0, 0);">4. 断言（零宽匹配，只判断位置，不消耗字符）</font>

| **语法** | **说明** | **示例** |
| :--- | :--- | :--- |
| `(?=...)` | 正向先行断言（后面必须是 ...） | `a(?=b)`<br/> 匹配 "ab" 中的 "a"（后面是 b） |
| `(?!...)` | 负向先行断言（后面不能是 ...） | `a(?!b)`<br/> 匹配 "ac" 中的 "a"（后面不是 b） |
| `(?<=...)` | 正向后行断言（前面必须是 ...） | `(?<=a)b`<br/> 匹配 "ab" 中的 "b"（前面是 a） |
| `(?<!...)` | 负向后行断言（前面不能是 ...） | `(?<!a)b`<br/> 匹配 "cb" 中的 "b"（前面不是 a） |

## <font style="color:rgb(0, 0, 0);">二、Python</font><font style="color:rgb(0, 0, 0);"> </font>`re`<font style="color:rgb(0, 0, 0);"> </font><font style="color:rgb(0, 0, 0);">模块常用函数</font>

`re` 模块是 Python 操作正则的核心，常用函数按「功能场景」分类，重点记参数与返回值：

### <font style="color:rgb(0, 0, 0);">1. 匹配与搜索（判断是否存在匹配）</font>

| **函数** | **说明** | **参数要点** | **返回值** |
| :--- | :--- | :--- | :--- |
| `re.match(pattern, string, flags=0)` | 从字符串**开头**匹配（仅匹配首位置） | `flags`<br/>：修饰符（如 `re.IGNORECASE`<br/> 忽略大小写） | 匹配对象（成功）/ `None`<br/>（失败） |
| `re.search(pattern, string, flags=0)` | 搜索字符串**任意位置**的第一个匹配 | 同 `match` | 匹配对象（成功）/ `None`<br/>（失败） |
| `re.findall(pattern, string, flags=0)` | 搜索所有匹配，返回列表 | 无额外参数 | 匹配结果列表（空列表表示无匹配） |
| `re.finditer(pattern, string, flags=0)` | 搜索所有匹配，返回迭代器（适合大量结果） | 同 `findall` | 匹配对象迭代器 |

#### <font style="color:rgb(0, 0, 0);">关键：匹配对象（</font>`Match`<font style="color:rgb(0, 0, 0);"> </font><font style="color:rgb(0, 0, 0);">对象）的用法</font>

`match`/`search` 成功后返回 `Match` 对象，核心方法：

* `group(n=0)`：提取第 n 个分组的结果（n=0 取整个匹配，命名分组用 `group("name")`）；
* `groups()`：返回所有分组的结果元组；
* `span()`：返回匹配结果的起止索引（元组 `(start, end)`）。

示例：

```python
import re
text = "My phone number is 138-1234-5678"
pattern = r'(\d{3})-(\d{4})-(\d{4})'  # 分组匹配手机号

# search 找第一个匹配
result = re.search(pattern, text)
print(result.group())  # 整个匹配：138-1234-5678
print(result.group(1)) # 第1组：138
print(result.span())  # 索引：(19, 31)

# findall 找所有匹配
print(re.findall(pattern, text))  # [('138', '1234', '5678')]
```

### <font style="color:rgb(0, 0, 0);">2. 替换与分割（修改字符串）</font>

| **函数** | **说明** | **参数要点** | **返回值** |
| :--- | :--- | :--- | :--- |
| `re.sub(pattern, repl, string, count=0, flags=0)` | 替换匹配内容（最常用） | `repl`<br/>：替换字符串（可含 `\1`<br/> 引用分组）；`count=0`<br/> 表示替换所有 | 替换后的新字符串 |
| `re.subn(pattern, repl, string, count=0, flags=0)` | 替换并返回替换次数 | 同 `sub` | 元组 `(新字符串, 替换次数)` |
| `re.split(pattern, string, maxsplit=0, flags=0)` | 按匹配规则分割字符串 | `maxsplit`<br/>：最大分割次数（0 表示无限制） | 分割后的列表 |

示例：

**python**

运行

```python
# 替换：将单独的 i 改为 I（之前的需求）
text = "i hope you like it: i"
corrected = re.sub(r'\bi\b', 'I', text)
print(corrected)  # I hope you like it: I

# 替换：手机号脱敏（中间4位变*）
phone = "138-1234-5678"
desensitized = re.sub(r'(\d{3})-(\d{4})-(\d{4})', r'\1-****-\3', phone)
print(desensitized)  # 138-****-5678

# 分割：按逗号或空格分割
text = "a,b c;d"
split_result = re.split(r'[, ;]', text)  # 匹配逗号、空格、分号
print(split_result)  # ['a', 'b', 'c', 'd']
```

### <font style="color:rgb(0, 0, 0);">3. 编译正则（优化重复使用场景）</font>

如果同一个正则模式需要多次使用（如循环中匹配），建议用 `re.compile()` 编译为「正则对象」，提升效率：

**python**

运行

```python
# 编译正则（一次编译，多次使用）
pattern = re.compile(r'\d{3}-\d{4}')  # 匹配固话区号+号码
texts = ["010-1234", "021-5678", "abc"]

for text in texts:
    if pattern.search(text):  # 直接用编译后的对象调用方法
        print(f"匹配到：{text}")
# 输出：
# 匹配到：010-1234
# 匹配到：021-5678
```

### <font style="color:rgb(0, 0, 0);">4. 常用修饰符（</font>`flags`<font style="color:rgb(0, 0, 0);"> </font><font style="color:rgb(0, 0, 0);">参数）</font>

修饰符用于修改正则的匹配规则，常用：

| **修饰符** | **说明** | **示例** |
| :--- | :--- | :--- |
| `re.IGNORECASE`<br/>（`re.I`<br/>） | 忽略大小写匹配 | `re.search(r'abc', 'ABC', re.I)`<br/> 匹配成功 |
| `re.MULTILINE`<br/>（`re.M`<br/>） | 多行模式（`^`<br/> 匹配行首，`$`<br/> 匹配行尾） | `re.findall(r'^Hello', 'Hello\nHello', re.M)`<br/> 匹配两次 |
| `re.DOTALL`<br/>（`re.S`<br/>） | 点号匹配所有字符（包括换行 `\n`<br/>） | `re.search(r'a.b', 'a\nb', re.S)`<br/> 匹 |

# 特殊语法

## 复数

在记录数字的时候，可以使用J来代替i作为记录，计算也能够正常计算

## 字符串拼接

直接“”+“”就可以

## 字符串引用

### 1.使用f快速格式化

`f"我{n}岁"`

### 2.使用%s方式

`"他们都说%s真不错!"%major`

`"%s的学生录取分数线是%d,颜值平均高达%f"%(major,score,face_score)`

其中的第一个%是变量的类型，第二个%是变量

`%(宽度).(精度)`

注意这里%可以控制浮点数精度

### 3.使用format

`"我爱玩{}".format("原神")`

`"人生就是不停地{0}{0}{1}{1}{1}{1}{1}{1}".format(up,down)`

"`我叫{name},我今年{age}岁了".format(age=34,name="python")`

使用format直接替换

## 运算符

x//y地板除，向下取整

% 余数

！=不等于

|求并集   &求交集   -求差集   ^求对称差集

in用于成员检测，遍历，成员是不是属于某一个序列的判断

## 列表推导式

`[表达式 for 变量 in 可迭代对象]`

对可迭代对象（如列表、字符串）的每个元素，执行「表达式」运算，结果组成新列表。

`[表达式 for 变量 in 可迭代对象 if 条件]`

先筛选出满足「条件」的元素，再执行表达式，结果组成新列表。

`[表达式 for 变量1 in 可迭代1 for 变量2 in 可迭代2]`

等价于嵌套循环（先循环可迭代 1，再循环可迭代 2），顺序和嵌套一致。

## 函数

```python
def 函数名(参数列表):
    函数体（要执行的逻辑）
    return 返回值  # 可选，无返回值则默认返回 None
```

* `def`：关键字，标记 “定义函数”；
* 函数名：自定义名称（遵循变量命名规则，如小写 + 下划线）；
* 函数体：缩进的代码（必写，哪怕只有一行）；
* `return`：可选，用于返回结果（执行到`return`会直接退出函数）。

### 位置参数：

def 函数名(参数1, 参数2)，必须按顺序传入，个数匹配 def(x1, x2)

### 默认参数：

def 函数名(参数=默认值) 可省略，省略时用默认值 def power(x, n=2): ... → power(3)（等价3²）

### 关键字参数：

调用时用参数名=值，可打乱顺序，明确对应关系 add(b=3, a=2)（结果同2+3）

### 可变长参数：

\*args / \*\*kwargs,接收任意个参数（位置 / 关键字）,def sum\_all(\*args): ... → sum\_all(1,2,3,4)（求和）

### 缺省参数

就是定义了，但是没有传入值的参数

这种参数只会在初始化的时候初始化一次，然后就不会初始化了，保留之前的值

### 注意事项

默认参数必须放在位置参数后面（如def func(a, b=1)合法，def func(a=1, b)不合法）；

\*args接收多个位置参数，存为元组；\*\*kwargs接收多个关键字参数，存为字典；

调用时，位置参数要在关键字参数前面（如add(2, b=3)合法，add(a=2, 3)不合法）。

# 数据类型

## list（列表）

`s=[1,3,6,10]`

直接索引，有序

注意，字符串可能自己识别为由字符组成的数组

list\[A:B:C]:list的部分列表

其中A表示起始位置，B表示终止位置，C表示步长

注意是左闭右开

同时起始位置和终止位置能使用复数，即最后-1为最后一个索引

### list.append(obj)

作用：在列表末尾添加单个元素（不改变原元素类型，直接追加）（相当于把obj取出然后加进去）

`obj`：必须参数，要添加到列表的任意类型元素（可以是数字、字符串、列表、字典等）。

### list.index(value, start=0, end=len(list))

作用：查找指定元素在列表中首次出现的索引位置，若未找到则抛出 ValueError

`value`：必须参数，要查找的目标元素（需与列表中元素类型一致）。

`start`：可选参数，查找的起始索引（默认从 0 开始，即从列表开头查找）。

`end`：可选参数，查找的结束索引（默认到列表末尾，不包含该索引位置）。

### list.insert(index, obj)

作用：在列表指定索引位置插入单个元素（插入后原索引及后续元素向后移位）

`index`：必须参数，插入元素的目标索引（可为负数，负数表示从列表末尾倒数；若索引超出列表长度，则插入到末尾）。

`obj`：必须参数，要插入的任意类型元素（可以是数字、字符串、列表、字典等）。

### list.extend(iterable)

作用：将可迭代对象中的所有元素逐一添加到列表末尾（扩展列表长度，而非添加单个元素）（相当于把两个列表融合在一起）

`iterable`：必须参数，支持迭代的对象（如列表、元组、字符串、集合等，元素会被逐个追加）。

### list.pop(index=-1)

作用：移除列表指定索引位置的元素并返回该元素（默认移除并返回末尾元素）

`index`：可选参数，要移除元素的索引（默认值为 -1，即最后一个元素；若索引超出范围，会抛出 IndexError）。

### list.count(value)

作用：统计指定元素在列表中出现的总次数（若元素不存在，返回 0）

`value`：必须参数，要统计次数的目标元素（需与列表中元素类型一致）。

### list.sort(key=None, reverse=False)

作用：对列表进行原地排序（直接修改原列表，无返回值）

`key`：可选参数，指定一个函数用于对列表元素预处理后再排序（如 key=len 按元素长度排序、key=str.lower 忽略大小写排序，默认值为 None，按元素默认规则排序）。

`reverse`：可选参数，布尔值，控制排序顺序（默认值为 False，升序排列；设为 True 时，降序排列）。

### list.copy()

作用：创建列表的浅拷贝（仅复制列表本身，列表中的嵌套对象仅复制引用，不递归复制）

无额外参数（调用时无需传参）。

## dict（字典）

`stu_dict = {"周杰伦":99,"林俊杰":88,"张学友":77}`

键值索引，无序

### dict.get(key, default=None)

作用：获取字典中指定键对应的值，若键不存在则返回默认值（默认 None）

`key`：必须参数，要查找的目标键（可是任意不可变类型，如字符串、整数、元组）。

`default`：可选参数，键不存在时返回的默认值（默认值为 None，可指定任意类型）。

### dict.setdefault(key, default=None)

作用：获取字典中指定键对应的值；若键不存在，则添加该键并设值为默认值，返回默认值

`key`：必须参数，要查找或添加的目标键（可是任意不可变类型）。

`default`：可选参数，键不存在时的默认值（默认值为 None，可指定任意类型）。

### dict.update(other)

作用：用另一个字典或可迭代的键值对更新当前字典（键存在则覆盖值，不存在则新增）

`other`：必须参数，可迭代的键值对集合（如字典、元组列表 \[(k1,v1), (k2,v2)] 等）。

```plain
books = {"python程序设计":"张三","数据结构":"李四","计算机组成":"王五"}
new_book ={"深度学习":"周八"}
books.update(new_book)
```

### dict.pop(key, default=None)

作用：删除字典中指定键对应的键值对并返回该值；若键不存在，返回默认值（未指定默认值则抛 KeyError）

`key`：必须参数，要删除的目标键（可是任意不可变类型）。

`default`：可选参数，键不存在时返回的默认值（未指定则键不存在时抛出 KeyError）。

### dict.popitem()

作用：删除并返回字典中最后插入的键值对（Python 3.7+ 保证插入顺序，返回形式为 (key, value) 元组）

无额外参数（调用时无需传参；空字典调用会抛出 KeyError）。

### dict.clear()

作用：清空字典中所有键值对，使字典变为空字典

无额外参数（调用时无需传参）。

### dict.keys()

作用：返回字典中所有键的视图对象（动态关联原字典，原字典修改后视图会同步更新）

无额外参数（调用时无需传参）。

### dict.values()

作用：返回字典中所有值的视图对象（动态关联原字典，原字典修改后视图会同步更新）

无额外参数（调用时无需传参）。

### dict.items()

作用：返回字典中所有键值对的视图对象（每个元素为 (key, value) 元组，动态关联原字典，同步更新）

无额外参数（调用时无需传参）。

## set（集合）

`major_set = {"网安","警指","治安","网安"}`

无序可变

自动去除重复元素，且打乱无序

### set.add(element)

作用：向集合中添加单个元素（集合自动去重，添加已存在的元素无效果

`element`：必须参数，要添加的元素（必须是不可变类型，如整数、字符串、元组；不能是列表、字典等可变类型，否则抛 TypeError）。

### set.remove(element)

作用：删除集合中的指定元素，元素不存在则抛出 KeyError

`element`：必须参数，要删除的目标元素（不可变类型）。

### set.discard(element)

作用：删除集合中的指定元素，元素不存在时无操作（不抛异常）

`element`：必须参数，要删除的目标元素（不可变类型）。

### set.pop()

作用：随机删除并返回集合中的一个元素（集合无序，无法指定索引）

无额外参数（调用时无需传参；空集合调用会抛出 KeyError）。

### set.clear()

作用：清空集合中所有元素，使集合变为空集合

无额外参数（调用时无需传参）

## tuple（元组）

### tuple.count(value)

作用：统计指定元素在元组中出现的总次数（若元素不存在，返回 0）

`value`：必须参数，要统计次数的目标元素（需与元组中元素类型一致）。

### tuple.index(value, start=0, end=len(tuple))

作用：查找指定元素在元组中首次出现的索引位置，若未找到则抛出 ValueError

`value`：必须参数，要查找的目标元素（需与元组中元素类型一致）。

`start`：可选参数，查找的起始索引（默认从 0 开始）。

end`：`可选参数，查找的结束索引（默认到元组末尾，不包含该索引位置）。

### tuple()

作用：将可迭代对象（如列表、字符串、集合等）转换为元组（空参数时返回空元组）

可迭代对象：可选参数，要转换为元组的可迭代对象（如 list、str、set 等，不传参则返回 ()）。

## str（字符串）

### str.find(sub, start=0, end=len(str))

作用：从字符串左侧开始查找子串，返回首次出现的索引；未找到则返回 -1

`sub`：必须参数，要查找的目标子串（字符串类型）。

`start`：可选参数，查找的起始索引（默认从 0 开始）。

`end`：可选参数，查找的结束索引（默认到字符串末尾，不包含该索引位置）。

### str.rfind(sub, start=0, end=len(str))

作用：从字符串右侧开始查找子串，返回首次出现的索引（即最右侧匹配的索引）；未找到则返回 -1

`sub`：必须参数，要查找的目标子串（字符串类型）。

`start`：可选参数，查找的起始索引（默认从 0 开始）。

`end`：可选参数，查找的结束索引（默认到字符串末尾，不包含该索引位置）。

### str.split(sep=None, maxsplit=-1)

作用：按指定分隔符拆分字符串，返回拆分后的列表（默认按任意空白字符拆分，自动忽略首尾空白）

`sep`：可选参数，拆分的分隔符（字符串类型，默认 None 表示按空格、制表符、换行符等任意空白字符拆分）。

`maxsplit`：可选参数，最大拆分次数（默认 -1 表示无限制拆分；设为 n 则最多拆分 n 次，返回 n+1 个元素）。

### str.join(iterable)

作用：将可迭代对象中的字符串元素，用当前字符串作为连接符拼接成一个新字符串

`iterable`：必须参数，包含字符串元素的可迭代对象（如列表、元组、字符串等；元素需为字符串类型，否则抛出 TypeError）。

### str.capitalize()

作用：将字符串首字母转为大写，其余字符转为小写，返回新字符串（原字符串不变）

无额外参数（调用时无需传参）。

### str.swapcase()

作用：反转字符串中所有字符的大小写（大写转小写，小写转大写），返回新字符串（原字符串不变）

无额外参数（调用时无需传参）。

### str.title()

作用：将字符串中每个单词的首字母转为大写，其余字母转为小写（单词以空白字符分隔），返回新字符串（原字符串不变）

无额外参数（调用时无需传参）。

### str.strip(chars=None)

作用：移除字符串首尾指定的字符（默认移除首尾空白字符，包括空格、制表符\t、换行符\n、回车符\r等），返回新字符串（原字符串不变）

`chars`：可选参数，指定要移除的字符集合（字符串类型，每个字符均为要移除的目标；默认 None 时，仅移除首尾空白字符）。

### str.partition(sep)

作用：将字符串按照指定的分隔符 sep 进行分割，返回一个包含三个元素的元组 (分隔符左侧部分, 分隔符本身, 分隔符右侧部分)；若字符串中找不到该分隔符，则返回 (原字符串, '', '')（原字符串、空字符串、空字符串）。

`sep`：必选参数，用于分割的分隔符（字符串类型，长度可任意，如单个字符、多个字符），不能为空字符串（否则会抛出 ValueError）。

# 函数使用方法

## 自带函数

### import

```plain
import A
from A import B as C
```

以sleep为例子

```python
import time                  
print("首长好")
time.sleep(3)
print("同志们辛苦了")
```

从A中获取B函数

如果是`import A`

使用的时候需要`A.需要使用的函数()`

但是如果是from A import B

就相当于直接定义在本地中，使用的时候可以直接`需要使用的函数()`

注意如果import D（D为本地定义的文件）

如果D中有直接执行的内容，没有写<code>if _ _ name _ _ == "main":</code>的话就会直接在当前文件执行

### id(A)

作用：输出地址

`A`：需要求地址的变量

### type(A)

作用：输出变量类型

A：需要输出的变量

### ord(A)

作用：字符转换成unicode

A：需要转换成unicode的编码

### <font style="color:rgba(0, 0, 0, 0.85);">print (\*objects, sep=' ', end='\n', file=sys.stdout, flush=False)</font>

<font style="color:rgba(0, 0, 0, 0.85);">作用：将指定对象转换为字符串后输出到指定输出流（默认是控制台）</font>

<code><font style="color:rgba(0, 0, 0, 0.85);">*objects</font></code><font style="color:rgba(0, 0, 0, 0.85);">：可选参数，接收一个或多个任意类型的对象（可零个，此时输出空行），多个对象用逗号分隔。</font>

<code><font style="color:rgba(0, 0, 0, 0.85);">sep</font></code><font style="color:rgba(0, 0, 0, 0.85);">：可选参数，指定多个对象输出时的分隔符，默认值为空格（' '）。</font>

<code><font style="color:rgba(0, 0, 0, 0.85);">end</font></code><font style="color:rgba(0, 0, 0, 0.85);">：可选参数，指定输出结束时追加的字符，默认值为换行符（'\n'）。</font>

<code><font style="color:rgba(0, 0, 0, 0.85);">file</font></code><font style="color:rgba(0, 0, 0, 0.85);">：可选参数，指定输出流对象（需支持 write () 方法），默认值为 sys.stdout（控制台输出），可指定为文对象等。</font>

<code><font style="color:rgba(0, 0, 0, 0.85);">flush</font></code><font style="color:rgba(0, 0, 0, 0.85);">：可选参数，布尔值，指定是否强制刷新输出流，默认值为 False（缓冲输出），True 表示立即刷新。</font>

### reversed(seq)

<font style="color:rgba(0, 0, 0, 0.85);">作用：对可反转的可迭代对象进行反向迭代，返回反向迭代器（不修改原对象）</font>

<code><font style="color:rgba(0, 0, 0, 0.85);">seq</font></code><font style="color:rgba(0, 0, 0, 0.85);">：必须参数，支持反向迭代的可迭代对象（如列表 list、元组 tuple、字符串 str、range 等，不支持集合 set、字典 dict 等无序对象）。</font>

### round(number, ndigits=None)

作用：四舍五入输入的number

`number`：给出需要进行操作的书

`ndigits`：给出需要四舍五入的位数，计算方法是小数点后几位

### min(iterable, \*\[, key, default])

作用：找出数组中最小的数

`iterable`：必须参数，支持迭代的对象（如列表 `list`、元组 `tuple`、字符串 `str`、集合 `set` 等）。

`key`：可选参数，指定一个函数，用于对可迭代对象中的每个元素先进行处理，再根据处理结果比较大小（类似 `sorted()` 的 `key` 参数）。

可以为`len`：长度，`iterable.lower()`：转换为小写等，相当于直接后面跟一个后缀函数

`default`：可选参数，当 `iterable` 为空时返回的默认值（若不指定，空可迭代对象会抛出 `ValueError`）。

### max(iterable, \*\[, key, default])

作用：找出数组中最大的数

`iterable`：必须参数，支持迭代的对象（如列表 `list`、元组 `tuple`、字符串 `str`、集合 `set` 等）。

`key`：可选参数，指定一个函数，用于对可迭代对象中的每个元素先进行处理，再根据处理结果比较大小（类似 `sorted()` 的 `key` 参数）。

可以为`len`：长度，`iterable.lower()`：转换为小写等，相当于直接后面跟一个后缀函数

`default`：可选参数，当 `iterable` 为空时返回的默认值（若不指定，空可迭代对象会抛出 `ValueError`）。

### divmod(a, b)

作用：接收两个数字类型的参数，返回一个包含商和余数的元组 (a // b, a % b)，即同时计算整数除法的商和取余的结果。

`a`：必选参数，被除数，必须是整数或浮点数（浮点数仅当能整除时返回整数商，否则商为浮点数）。

`b`：必选参数，除数，必须是整数或浮点数（不能为 0，否则抛出 ZeroDivisionError）。

### pow(base, exp, mod=None)

作用：计算幂运算，返回 base^exp 的结果；若指定 mod，则返回 (base^exp) % mod（该方式比先算幂再取模更高效）。

`base`：必选参数，底数，可为整数、浮点数等数值类型。

`exp`：必选参数，指数，可为整数（正数、负数、0）；若 mod 存在，exp 必须为非负整数。

`mod`：可选参数，模数，必须是整数且大于 0；若指定，仅返回幂运算结果对 mod 取余的值。

### enumerate(iterable, start=0)

作用：将一个可迭代对象（如列表、元组、字符串）组合为一个索引序列，返回枚举对象（可迭代），每个元素是 (索引, 元素) 的元组。

`iterable`：必选参数，可迭代对象（如列表、元组、字符串、生成器等）。

`start`：可选参数，指定索引的起始值，默认值为 0。

### map(function, iterable, ...)

作用：将指定函数依次作用于可迭代对象的每个元素，返回一个迭代器（map 对象）；若传入多个可迭代对象，函数需接收对应数量的参数，依次取每个可迭代对象的元素传入函数。

`function`：必选参数，可调用对象（函数、lambda 表达式等）；若为 None，则默认将多个可迭代对象的元素打包为元组。

`iterable`：必选参数（可多个），一个或多个可迭代对象（列表、元组、字符串等）。

### <font style="color:rgb(0, 0, 0);">open(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True, opener=None) as file:</font>

作用：打开一个文件并返回对应的文件对象（后续文件操作均基于该对象），若文件不存在且模式允许则创建，模式不允许则抛出异常。

`file`：必须参数，文件路径（字符串，支持绝对路径 / 相对路径，如 `'data.txt'` 或 `'/home/user/data.txt'`）。mode：可选参数，文件打开模式（默认值 `'r'`，常用值如下）：

* `'r'`：只读模式（默认），文件不存在则报错；
* `'w'`：写入模式，清空原有内容，文件不存在则创建；
* `'a'`：追加模式，在文件末尾写入，文件不存在则创建；
* `'r+'`：读写模式，文件不存在则报错；
* `'w+'`：读写模式，清空原有内容，文件不存在则创建；
* `'a+'`：读写模式，追加写入，文件不存在则创建；
* 后缀 `'b'`：二进制模式（如 `'rb'`/`'wb'`），用于非文本文件（图片 / 音频等）。buffering：可选参数，缓冲策略（默认 `-1` 表示使用系统默认缓冲，`0` 关闭缓冲（仅二进制模式），`1` 行缓冲，>1 表示指定缓冲区大小）。

`encoding`：可选参数，文件编码（仅文本模式有效，如 `'utf-8'`/`'gbk'`）。

`errors`：可选参数，编码错误处理方式（如 `'ignore'`/`'replace'`）。

`newline`：可选参数，换行符处理（如 `None`/`'\n'`/`'\r\n'`）。

`closefd`：可选参数，是否关闭文件描述符（默认 `True`，若为 `False` 则 file 需是文件描述符）。

`opener`：可选参数，自定义文件打开器（需是可调用对象，返回文件描述符）。

### ![1767834856994-ba19ea74-36ce-445b-8ca1-31cd7ea32073.png](./img/N9PuQgqwmMlFhUkL/1767834856994-ba19ea74-36ce-445b-8ca1-31cd7ea32073-250098.png)

## fractions

### fractions.fraction(A, B)

作用：输出分数

`A`：分子

`B`：分母

## decimal

### decimal.Decimal(A)

作用：高精度浮点数

`A`：浮点数

## random

### random.uniform(a, b)

作用：生成一个指定范围内的随机浮点数（包含 a 和 b，支持 a > b 或 a < b）

库：random（需导入 import random）

`a`：必须参数，随机浮点数的一个边界（可以是整数或浮点数）。

`b`：必须参数，随机浮点数的另一个边界（可以是整数或浮点数）。

### random.randint(a, b)

作用：生成一个指定整数范围内的随机整数（闭区间 \[a, b]，包含 a 和 b，要求 a ≤ b）

`a`：必须参数，整数范围的下界（必须是整数）。

`b`：必须参数，整数范围的上界（必须是整数）。

### random.randrange(start, stop=None, step=1)

作用：从指定整数序列中随机选择一个整数（序列由 start、stop、step 定义，不包含 stop）

`start`：必须参数，序列的起始值（默认从 0 开始，若仅传一个参数则视为 stop，start 默认为 0）。

`stop`：可选参数，序列的结束值（不包含，若不指定则 start 视为 stop，序列从 0 到 start-1）。

`step`：可选参数，序列的步长（默认值为 1，需为正整数，用于生成 start, start+step, start+2\*step... < stop 的序列）。

### random.choice(seq)

作用：从非空可迭代对象（序列）中随机选择一个元素

`seq`：必须参数，非空的可迭代对象（如列表 list、元组 tuple、字符串 str 等，不能为空）。

### random.sample(population, k)

作用：从指定总体（可迭代对象）中随机抽取 k 个不重复的元素，返回新列表（不修改原总体）

`population`：必须参数，支持随机抽取的总体（可迭代对象，如列表、元组、集合等，元素可重复但抽取后无重复）。

`k`：必须参数，抽取的元素个数（必须是非负整数，且 k ≤ population 的长度，否则抛出 ValueError）。

### random.shuffle(x)

作用：对可修改的序列（如列表）进行原地随机打乱（直接修改原序列，无返回值）

`x`：必须参数，可修改的序列（如列表 list，不支持元组、字符串等不可变类型，否则抛出 TypeError；序列为空时无操作）。

## copy

### copy.deepcopy(x)

作用：创建对象（包括列表、字典等可迭代对象）的深拷贝（递归复制所有嵌套对象，原对象与拷贝对象完全独立，互不影响）

`x`：必须参数，要进行深拷贝的对象（如列表、嵌套列表、字典等，需先导入 copy 模块：import copy）。

## math

### math.ceil(x)

作用：对数值进行向上取整（返回大于或等于 x 的最小整数）

`x`：必须参数，需要向上取整的数值（可以是整数或浮点数，需先导入 math 模块：import math）。

### math.sqrt(x)

作用：计算非负数值的平方根（返回浮点数，x 为负数时抛出 ValueError）

`x`：必须参数，需要计算平方根的非负数值（可以是整数或浮点数，需先导入 math 模块：import math）。

## OS

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.getcwd()</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：获取当前工作目录的绝对路径（即 Python 脚本当前运行的目录路径）</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">参数：无参数</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.chdir(path)</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：改变当前工作目录到指定的路径</font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">path</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：必须参数，字符串类型，指定要切换到的目标目录路径（可以是绝对路径或相对路径）</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.path.exists(path)</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：判断指定的路径（文件或目录）是否存在，存在返回 True，不存在返回 </font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">Falsepath</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：必须参数，字符串类型，要检查是否存在的文件 / 目录路径</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.path.isdir(path)</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：判断指定的路径是否为一个存在的目录，是则返回 True，否则返回 </font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">Falsepath</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：必须参数，字符串类型，要检查的路径</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.path.isfile(path)</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：判断指定的路径是否为一个存在的文件，是则返回 True，否则返回 </font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">Falsepath</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：必须参数，字符串类型，要检查的路径</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.listdir(path='.')</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：返回指定目录下的所有文件和子目录的名称列表（不包含路径，仅返回名称）</font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">path</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：可选参数，字符串类型，默认值为当前目录（'.'），指定要列出内容的目录路径</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.mkdir(dir\_path)</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：创建单层目录（文件夹），如果目录已存在或上级目录不存在，会抛出异常</font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">dir_path</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：必须参数，字符串类型，要创建的目录路径（绝对路径或相对路径）</font>

### <font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">os.remove(file\_path)</font>

<font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">作用：删除指定的文件（注意：不能删除目录），如果文件不存在会抛出异常</font>

<code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">file_path</font></code><font style="color:rgb(31, 35, 41);background-color:rgba(0, 0, 0, 0);">：必须参数，字符串类型，要删除的文件路径</font>

###

