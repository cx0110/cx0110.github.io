---
title: "Python 基础"
subtitle: "Python编程语言基础教程"
summary: "Python编程语言的基础知识，包括语法、数据类型、控制结构和面向对象编程"
authors:
  - admin
tags:
  - Python
  - 基础教程
  - 编程语言
categories:
  - Python
date: 2022-01-19T08:04:00+08:00
lastmod: 2025-12-24T10:00:00+08:00
featured: false
draft: false
image:
  filename: python-logo.svg
  focal_point: Smart
  preview_only: false
---

# Python

### 数据类型

不可变：int、float、str、tuple、bool

可变：list、set、dict

可迭代：str、list、dict、tuple、set

#### Str 字符串

```python
len(s)  # 统计字符串长度
ord(s)  # 字符 =》ASCII
cha(s)  # ASCII =》字符
' '.join(s)  # 拼接字符串；
[::-1]  # 反转字符串
[a: b]  # 按下标a~b切割
.split()  # 切割字符串(默认空字符,会保存成列表)
.splitlines()  # 按行切割
.strip()  # 去除两侧字符(默认空字符)
.lstrip()  # 去除左边的特定字符
.rstrip()  # 去除右边的特定字符
.zfill(n)  # 返回指定 n长度字符串，不足的前面补0
.count(i)  # 计算 i 在字符串s中出现的次数
.find(i)  # 查找字符串，并返回 i 第一次出现的下标；	rfind()  # 反向查找字符串
.index(i)  # 查询元素返回 i 第一次出现的下标(若不在列表中则会报错，可以指定开始、结束范围)
.replace(old, new, max)  # 把old替换成new(新字符串)，max指定最多替换次数
.upper()  # 所有小写转大写；	lower()  # 所有大写转小写；	
.swapcase()  # 大小写互转；	capitalize()  # 字符串首字母转大写；	title()  # 每个单词首字母大写；	
.isupper()  # 判断是否全是大写；	islower()  # 判断是否全是小写；
.isalpha()  # 判断是否只是字母
.isdigit()  # 判断是否只是数字
.isdecimal()  # 判断是否只包含十进制字符
.startswith()  # 判断是否以特定字符开头；	endswith()  # 判断是否以特定字符结尾
.isalnum()  # 判断是否只是字母或数字
isinstance(s, type)  # 判断是否为指定类型
.rjust(3, '0')  # 右对齐，用0填充至3长度
```

```python
b''  # 表示bytes类型
u''  # 表示unicode字符串
r''  # 非转义字符
f''  # 格式化操作
	s1 = 'good man'
	f'LP is a {s1}.'  # LP is a good man.
```

#### List 列表

```python
.len()  # 统计列表长度
' '.join(lt)  # 将列表拼接成字符串(按' '拼接)
lt.append(a)  # 追加元素a到末尾
lt.extend(lt2)  # 将可迭代对象a的元素展开追加到列表末尾
for i, v in enumerate(lt)  # 遍历列表(可以同时获取元素及下标)，可设置起始位置
.insert(i, a)  # 指定i下标位置插入元素a
.index()  # 查询元素返回第一次出现的下标(若不在列表中则会报错，可以指定开始、结束范围)
.remove(v)  # 删除指定值的元素(只删第一个)
.pop(i)  # 弹出指定下标的元素(默认最后一个)
.count()  # 统计元素出现的次数
.clear()  # 清空列表
.copy()  # 拷贝一个列表
[::-1]  # 逆序
.reverse()  # 逆序
.sort()  # 原对象升序排序  # 	sort(reverse=True)  # 降序排序；	
sorted(lt)  # 排序，返回新对象，可以用于多种可迭代对象
```

##### Collections(计数器与队列)

**Counter**

```python
from collections import Counter

c = Counter(lt)
dict(c)  # 获取元素及出现次数(字典形式显示)
c.most_common(n)  # 获取出现次数最多的元素及次数，指定获取前n个
```

**deque**

```python
d = deque(lt)  # 注：列表函数同样用
d.append(a)  # 从右侧添加元素a
d.appendleft(a) # 从左侧添加元素a
d.remove(a)  # 删除元素a
d.pop()  # 从右侧弹出元素(不能指定下标)
d.popleft()  # 从左侧弹出元素
d.extend(lt2)  # 从右侧扩充序列
d.extendleft(lt2)  # 从左侧扩充序列
d.rotate(n)  # 循环移动，n正右移n次，n负左移n次
```

##### Itertools(排列组合)

```python
it = itertools.permutations(lt, n)  # 从可迭代对象lt中取出n个元素，所有的可能就是排列(有序)，会重复
it = itertools.combinations(lt, n)  # 组合，按lt中顺序排列，且不重复
it = itertools.product(lt, lt2, ltn)  # 笛卡尔成绩，多个序列中的组合
it = itertools.product(lt, repeat=n)  # 相等于n个lt，功能同上
for i in it:
    print(i)
```

#### Tuple 元组

```python
len(t)  # 统计长度
index()  # 获取指定元素的下标
count()  # 统计指定元素出现的次数
max(t)  # 最大值
min(t)  # 最小值
```

#### Set 集合

```python
len(s)  # 计算长度
add()  # 添加元素
remove()  # 删除元素(不存在会报错)
discard()  # 删除元素(不存在不会报错)
pop()  # 随机删除并返回
clear()  # 清空元素
s1 | s2  # 并集(所有元素)
s1 & s2  # 交集(相同元素)
s1 ^ s2  # 对称差集(不同元素)
s1 - s2  # 差集(s1有s2没有元素)
s1 <= s2  # s1是否是s2的子集
s1 >= s2  # s1是否是s2的父集
s1.union(s2)  # 并集
s1.intersection(s2)  # 交集
s1.intersection_update(s2)  # 交集(会覆盖原来的集合)
s1.isdisjoint(s2)  # 是否 没有 交集
s1.issubset(s2)  # s1是否是s2的子集
s1.issuperset(s2)  # s1是否是s2的父集(超集)
```

#### Dict 字典操作

```python
d[n]  # 获取n的值
.get(n)  # 获取n键的值，没有返回None，可指定默认值, 对原字典无修改
.setdefault()  #  无值时使用默认值，并将默认值写入原字典
.keys()  # 遍历字典，获取键
.values()  # 遍历字典，获取值
.items()  # 遍历字典，同时获取键和值
.update()  # 更新字典(存在覆盖，不存在添加)
.pop(n)  # 删除 键n 并返回
del d[n] # 删除 键n
.clear()  # 清空元素
a.update(b)  # 将字典b 合并到 字典a
c = dict(a, **b)  # 将字典a,b合并，返回新字典
```

`__和_`区别

```python
_单前置下划线  # 表示属性和方法的私有化
__双前置下划线  # 避免和子类属性命名冲突，不能直接被调用
xx__双后置下划线  # 避免与python关键字冲突
__xx__双前后下划线  # 表示魔法属性/魔法方法
```

```python
class A(object):
    def __method(self):
        print("I'm a method in A")

    def method(self):
        self.__method()


class B(A):
    def __method(self):
        print("I'm a method in B")

    def str__(self):
        print("I'm a method in B__")


if __name__ == "__main__":
    a = A()
    a.method()  # I'm a method in A
    b = B()
    b.method()  # I'm a method in A
    b.str__()  # I'm a method in B__
```



### 循环

#### For

```python
for i in range(n)
	pass

for i, v in enumerate(lt):
    pass
```

#### While

```python
while 1:  # 死循环
    pass

i = 0
while i < len(lt):  # 循环列表时，每次循环会检查列表长度
    
    if i == 3:
        continue  # 跳出本循环，开始下次循环
        break  # 终止while循环
    pass
```

### 迭代器生成器

#### 迭代器

- 可以被 next()函数调用不断返回下个值，叫迭代器
- iter()：创建迭代器。字符串，列表，元组 都可以用 创建迭代器
- next()  `__next__()`：输出迭代器下一个元素，且元素只能用一次，迭代完继续取值会报错 StopIteration

```python
arr = [0, 1, 2, 3, 4]

ite = iter(arr)  # 转为迭代器
print(ite)  # <list_iterator object at 0x0000023C07E0A780>

print(ite.__next__())  # 0
print(next(ite))  # 1
for i in ite:
    print(i)  # 2, 3, 4
```

#### 生成器

- 小括号的列表生成式是生成器
- 使用 yield 关键字的函数也叫生成器，生成器也是一个迭代器

```python
gen = (i for i in range(5))
print(gen)  # <generator object <genexpr> at 0x0000025F87C6B8E0>

print(gen.__next__())  # 0
print(next(gen))  # 1
for i in gen:
    print(i)  # 2, 3, 4
```

### 递归

- 一种算法，在函数内调用它本身，一直反复，且必须有结束条件
- 优点：代码简单，容易理解

### 深浅拷贝

**直接赋值**

- 对象的引用， 

**浅拷贝**

- 只拷贝父对象，但子对象只会增加一个引用。也可以用 copy()

**深拷贝**

- 父对象和子对象都拷贝

```python
import copy

arr = [1, 2, [3, 4]]
arr1 = arr
arr2 = copy.copy(arr)  # 浅拷贝
arr3 = copy.deepcopy(arr)  # 深拷贝

print(arr is arr)  # 判断是否是同一个对象的多个引用
```

### 面向对象

面向过程：步骤化。一步一步实现步骤

面向对象：行为化。按功能或特点划分封装成类

- 特点：封装、继承、多态
- 优点：灵活性、重用性好
- 缺点：因为调用要先实例化，所以性能比面向过程差一些

### 函数

#### 内置系统函数

```python
print()  # 打印
input()  # 输入
type()  # 获取类型
len()  # 统计元素个数
range()  # 自动生成序列
enumerate()  # 枚举可迭代对象，同时列出数据和数据下标
ord()  # 字符转ASCII
chr()  # ASCII转字符
int()  # 转为十进制，去除小数点后位数
bin()  # 十转二进制
oct()  # 十转八进制
hex()  # 十转十六进制
abs()  # 求绝对值
max()  # 最大值
min()  # 最小值
sum()  # 求和
pow()  # 求幂
round()  # 四舍五入
round(3.12356, n)  # 小数后保留n位
```

#### 常用函数

```python
os.system('cls')  # 清屏操作
os.system('calc')  # 计算器
print(os.environ['path'])  # 获取环境变量
if ** else **  # 灵活使用
yield x  # 函数会返回yield后的内容，然后会停止在这里，用于生成器
iter()  # 可将可迭代对象转换为迭代器
gliobal n  # 声明n是全局变量(可以是多个)
nonlocal n  # 声明n是外层的局部变量
isinstance(a, type)  # 判断对象a是否是type类型的
```

##### Zip

- 将多个可迭代对象里边对应的元素打包成元组，返回其对象，只能使用一次。
- 若长度不一样，输出其对象最小长度

```python
a = ['a', 'b', 'c']
b = [1, 2, 3, 4]
c = ['A', 'B', 'C']

s1 = zip(a, b)
print(s1)  # <zip object at 0x000001F712A32EC8>

s2 = list(zip(a, b, c))
print(s2)  # [('a', 1, 'A'), ('b', 2, 'B'), ('c', 3, 'C')]

s3 = dict(zip(a, b))
print(s3)  # {'a': 1, 'b': 2, 'c': 3}

a2, a3 = zip(*zip(a, b))
print(a2, a3)  # ('a', 'b', 'c') (1, 2, 3)
```



##### Lambda(匿名函数)

- 匿名函数，也是一个表达式，可以赋值给变量
- 有独立的命名空间，访问不到外部变量
- 让代码更简洁

```python
lambda 参数: 表达式
lambda x, y: x + y
lambda d: d['age']
```

##### 递归

```python
return 表达式：递归
```

##### 装饰器

@ 函数名：装饰器(不改变原来函数)

##### Retry 函数重试

- 函数执行错误重试机制

```
pip install retry
```

```python
def retry(exceptions=Exception, tries=-1, delay=0, max_delay=None, backoff=1, jitter=0, logger=logging_logger):
    """Return a retry decorator.
    ：param exceptions：捕获异常或异常元组。 默认：Exception。
    ：param tries：Exception最大尝试次数。 默认值：-1（无限）。
    ：param delay：尝试之间的初始延迟。 默认值：0。
    ：param max_delay：延迟的最大值。 默认值：无（无限制）。
    ：param backoff：乘法器应用于尝试之间的延迟。 默认值：1（无退避）。
    ：param jitter：额外的秒数添加到尝试之间的延迟。 默认值：0。
               如果数字固定，则随机如果范围元组（最小值，最大值）
    ：param logger：logger.warning（fmt，error，delay）将在失败尝试中调用。
                    默认值：retry.logging_logger。 如果无，则记录被禁用。
    """
```

```python
from retry import retry

@retry(tries=3)  # 重试2次，共执行3次
def main():
	...
```



#### 高级函数

##### Map

- 根据指定函数对序列做出映射(函数，序列)

```python
# 每个元素+1
nums = [1, 2, 3]

def add(n):
    return n + 1

res = list(map(add, nums))
print(res)  # [2, 3, 4]

# 一行写法
res = list(map(lambda x: x+1, nums))
print(res)  # [2, 3, 4]
```

##### Filter

- 过滤序列，过滤掉不符合条件的元素，返回由符合条件元素组成的新列表(函数，可迭代对象)

```python
# 保留奇数
nums = [1, 2, 3, 4, 5]

def func(n):
    return n % 2 == 1

res = list(filter(func, nums))
print(res)  # [1, 3, 5]

# 一行写法
res = list(filter(lambda x: x % 2 == 1, nums))
print(res)  # [1, 3, 5]

```

##### Reduce

- 对参数序列中的元素进行累积(函数， 序列)

```python
## 实现1—100之和
from functools impor reduce


def add(a, b):
    return a + b

nums = [i for i in range(1, 101)]
res = reduce(add, nums)
print(res)  # 5050

# 一行写法
res = reduce(lambda x, y: x + y, [i for i in range(1, 101)])
print(res)
```

#### 模块函数(需要引入)

```python
import xx  # 引入xx包
from xx import yy  # 只引入xx包里的yy类(可引多个类)
from xx import yy as zz  # 引入模块中的指定内容，并且起别名
from xx import *  # 模糊导入，导入该模块中`__all__`列表指定的内容
```

isinstance(a, type)：判断对象a是否是type类型的

##### Inspect:

###### Isfunction

```python
from inspect import isfunction

isfunction(n)  # 判断标识符n是否是函数
```

##### Collections

###### Iterator,Iterable

```python
from collections import Iterator, Iterable

isinsratance(lt, Iterator)  # 判断lt是否是迭代器

isinsratance(lt, Iterable)  # 判断lt是否是可迭代对象
```

#### 函数注解

- 只是声明，运行代码不会强校验 

```python
# a: int		声明参数a类型为int
# -> int		声明返回类型为int
# -> List[int]	声明返回类型为数字列表

def add(a: int) -> int:
    return a + 1

print(add(1))  # 2

def demo(a: int, b: int) -> List[int]:
    return [a, b]

print(demo(1, 2))  # [1, 2]
```

函数性能器

```python
import cProfile

def func(n):
	pass

cProfile.run('func(n)')
```

### 类

```python
class 类名:  # 类的定义

self.  # 表示当前对象，就是调用该方法的对象

class B(A)  # B继承A
class C(A, B)  # C同时继承A和B

__  # 前面加俩下划线定义私有方法
@staticmethod  # 静态方法
@classmethod  # 类方法，创建对外的简易接口
@property  # 专门保护特有的属性

@abstractmethod  # 定义抽象方法，规定接口
repr(d)  # 返回对象的字符串显示
eval(r)  # 执行有效的python代码字符串
```

#### 魔法属性

```python
__doc__  # 类的描述信息
__module__  # 操作对象属于哪个模块
__class__  # 操作对象属于哪个类
```

#### 魔法方法

```python
__str__()  # 打印对象时会触发，str方法转换时会触发，打印对象时会打印该方法的返回值
__new__(cls)  # 创建实例
__init__()  # 构造方法/实例方法，初始化实例
__del__()  # 析构方法，当对象释放时会触发
__next__()  # 定义迭代器
__setattr__()  # 添加或设置属性时会自动触发
__getattr__()  # 获取指定的属性时会自动触发
__delattr__()  # 销毁对象的指定属性时会自动触发
__setitem__()  # 把对象当作字典，添加或设置属性时会自动触发
__getitem__()  # 把对象当作字典，根据键获取值时自动触发
__delitem__()  # 把对象当作字典，删除指定属性时自动触发
__call__()  # 把对象当作函数调用，该方法会自动触发
__repr__()  # 返回对象的字符串表示形式，使用repr函数处理时会自动触发
```

#### 实例方法

- 首个参数self，实例方法不能被直接调用

#### 静态方法

**@staticmethod**

- 修饰过的函数不需要实例化，可直接调用

#### 类方法

**@classmethod**

- 修饰过的函数不需要实例化，可直接调用。但第一个参数需要是自身类的cls参数

#### 修饰方法

@property

- 创建只读属性，新式类中返回属性值

```python
class Demo:
    a = 1

    def __init__(self):
        self.b = 2

    def aa(self):
        print('aa', self.a, self.b)

    @classmethod
    def bb(cls):
        print('bb', cls.a, cls().b)

    @staticmethod
    def cc():
        print('cc', Demo.a, Demo().b)

    @property
    def dd(self):
        return self.a


Demo().aa()  # aa 1 2
Demo.bb()  # bb 1 2
Demo.cc()  # cc 1 2
res = Demo().dd
print(res)  # dd 1
```

#### Super()

- 解决多继承问题的方法，广度优先顺序执行

```python
class A:
    def go(self):
        print("go A go!")

    def stop(self):
        print("stop A stop!")

    def pause(self):
        raise Exception("Not Implemented")


class B(A):
    def go(self):
        super(B, self).go()
        print("go B go!")


class C(A):
    def go(self):
        super(C, self).go()
        print("go C go!")

    def stop(self):
        super(C, self).stop()
        print("stop C stop!")


class D(B, C):
    def go(self):
        super(D, self).go()
        print("go D go!")

    def stop(self):
        super(D, self).stop()
        print("stop D stop!")

    def pause(self):
        print("wait D wait!")


class E(B, C):
    pass


a = A()
b = B()
c = C()
d = D()
e = E()

# 说明下列代码的输出结果

# a.go()  # go A go!
# b.go()  # go A go! \n go B go!
# c.go()  # go A go! \n go C go!
# d.go()  # go A go! \n go C go! \n go B go! \n go D go!
# e.go()  # go A go! \n go C go! \n go B go!

# a.stop()  # stop A stop!
# b.stop()  # stop A stop!
# c.stop()  # stop A stop! \n  # stop C stop!
# d.stop()  # stop A go! \n stop C go! \n stop D go!
# e.stop()  # go A go! \n go C go!

# a.pause()  # Exception: Not Implemented
# b.pause()  # Exception: Not Implemented
# c.pause()  # Exception: Not Implemented
# d.pause()  # wait D wait!
# e.pause()  # Exception: Not Implemented
```

### 闭包

- 引用了外部变量的内部函数
- 原理：在外函数中定义一个内函数，内函数里用了外函数的变量，并且外函数的返回值是内函数的引用，这就是一个闭包

```python
def outer(a):
    b = 2

    def inner():
        print(a + b)

    return inner

demo = outer(3)
demo()  # 5
```

### 装饰器

- 作用：给其他函数增加额外功能。多装饰器从下往上执行
- 原理：通过闭包实现

```python
def timeit(func):
    def inner():
        start_time = time.time()
        func()
        end_time = time.time()
        print(f'运行时间: {end_time - start_time}')

    return inner


@timeit
def func():
    print('func执行')
    time.sleep(2)

func()  # 运行时间: 2.0038506984710693
```

#### 带参数装饰器

```python
# 函数写法
def timeit(name=''):
    def outer(func):
        def inner():
            start_time = time.time()
            func()
            end_time = time.time()
            print(f'{name}运行时间: {end_time - start_time}')
        return inner
    return outer


@timeit('func函数')
def func():
    print('func执行')
    time.sleep(2)

func()  # func函数运行时间: 2.0038506984710693


# 类写法
class timeit:
    def __init__(self, name=''):
        self.name = name

    def __call__(self, func):
        def inner(*args, **kwargs):
            start_time = time.time()
            func()
            end_time = time.time()
            print(f'{self.name}运行时间: {end_time - start_time}')

        return inner


@timeit('func函数')
def func():
    print('func执行')
    time.sleep(2)


func()  # func函数运行时间: 2.0138235092163086
```

### 单例

- 保证类里边只有一个实例
- 实现方式：`__new__`、模块导入、用装饰器、使用类

`__new__`

- 先判断是不是存在实例，存在返回，不存在则创建。

```python
import threading

class Singleton(object):
    _instance_lock = threading.Lock()

    def __init__(self, *args, **kwargs):
        pass

    # 先判断是不是存在实例，存在返回，不存在则创建。
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            with Singleton._instance_lock:
                if not hasattr(cls, '_instance'):
                    Singleton._instance = object.__new__(cls)

        return Singleton._instance

obj1 = Singleton()
obj2 = Singleton()
print(obj1, obj2)
```

**模块导入**

- python模块就是单例模式，首次导入会建pyc文件，其他会直接导入这个文件

```python
# mysingleton.py

class Singleton:
    def foo(self):
        pass
    
singleton = Singleton()

# 导入
from mysingleton import Singleton
```

**装饰器**

- 装饰器外层定义字典用来存类的实例，之后每次先判断是不是存在实例，存在返回，不存在则创建。

```python
def singleton(cls):
    _instance = {}

    def _singleton(*args, **kwargs):
        if cls not in _instance:
            _instance[cls] = cls(*args, **kwargs)
        return _instance[cls]

    return _singleton


@singleton
class A:
    a = 1

    def __init__(self, x=0):
        self.x = x


a1 = A(2)
```

**使用类**

```python
class Singleton(object):

    def __init__(self):
        pass

    @classmethod
    def instance(cls, *args, **kwargs):
        if not hasattr(Singleton, "_instance"):
            Singleton._instance = Singleton(*args, **kwargs)
        return Singleton._instance
```

### 序列化

```python
import pickle

pickle.dumps()  # 序列化，会将对象转换为bytes

pickle.loads()  # 反序列化，从bytes中解析出对象
```

### Json

```python
import json
json.dumps()  # 将字典转换为JSON字符串
json.loads()  # 将JSON字符串转换为字典
```

### 编码

```python
from urllib.parse import urlencode
urlencode(d)  # 将字典进行URL编码
```



### 标准库

```python
datetime  # 为日期和时间处理同时提供了简单和复杂的方法
zlib  # 直接支持通用的数据打包和压缩格式：zlib，gzip，bz2，zipfile，以及 tarfile
random  # 提供了生成随机数的工具
math  # 为浮点运算提供了对底层C函数库的访问
sys  # 工具脚本经常调用命令行参数。这些命令行参数以链表形式存储于 sys 模块的 argv 变量
glob  # 提供了一个函数用于从目录通配符搜索中生成文件列表
os  # 提供了不少与操作系统相关联的函数
urllib  # 获取网页源码
```

### 异常处理

```python
try:
	# 正常执行
except <异常名>:
	# 异常执行
except <异常名>, 附加数据:
	# 异常执行
else:
    # 没有异常时会执行
finally:
	# 都执行
    raise Exception('手动抛出的异常')
```

### 日志

```python
import logging

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

logging.info('xxx')

# DEBUG：用于调试目的的低级系统信息
# INFO：一般系统信息
# WARNING：描述已发生的小问题的信息。
# ERROR：描述已发生的主要问题的信息。
# CRITICAL：描述已发生的严重问题的信息。
```



### 数学模块

##### Math

```python
import math

math.ceil(3.1)  # 向上进一
math.floor(3.9)  # 向下进一
math.sqrt(x)  # 返回数字x的平方根
math.radians(360)  # 度转换为弧度
math.degrees(math.pi)  # 弧度转换为度
```

##### Sys

```python
import sys

sys.argv  # 是一个列表，保存所有的命令行参数
```

##### Random 随机数

```python
import random

random.randint(a, b)  # 生成指定a~b范围随机整数
random.random()  # 生成0~1的随机小数
random.uniform(a,b)  # 生成a~b的随机小数
random.randrange(a, b, n)  # 生成a~b范围随机整数，可指定步幅n
random.choice(lt)  # 从容器对象或字符串随机返回一个元素
random.sample(lt, 3)  # 从容器对象返回指定个数元素的列表
random.choices(lt)  # 从容器对象返回一个元素的列表，samlp函数个数为1的情况
random.shuffle(lt)  # 将列表随机打乱
```

##### 算术运算

`__add__、__radd__、__iadd__`：加法

`__sub__、__rsub__、__isub__`：减法

`__mul__、__rmul__、__imul__`：乘法

`__truediv__、__rtruediv__、__itruediv__`：除法

`__mod__、__rmod__、__imod__`：求余

##### 关系运算

`__gt__、__lt__、__eq__`：大于、小于、等于

`__ge__、__le__、__ne__`：大于等于、小于等于、不等于

### 时间模块

#### Time

```python
import time

t = time.time()  # 获取时间戳，1499825149.257892，(从1970-01-01 00:00:00到此刻的秒数)
round(time.time())  # 秒级时间戳，10位
round(time.time() * 1000)  # 毫秒级时间戳，13位
round(time.time() * 1000000)  # 微秒级时间戳，16位

time.sleep(t)  # 睡眠指定t的秒数(可以是小数)
time.localtime(t)  # 将时间戳转换为时间日期对象(time.struct_time)，(默认当前时间戳)，包含时区
time.gmtime(t)  # 将时间戳转换为 time.struct_time 对象，不带时区
time.mktime(t)  # 根据年月日等信息创建时间戳
time.timezone(t)  # 7+0时区与当前系统时区相差的秒数

%Y  # 年(4位)
%y  # 年(2位)
%m  # 月
%d  # 日
%D  # 月/日/年
% H  # 时
%M  # 分
%S  # 秒
%w  # 星期
%W  # 本周是今年的第几周

t = time.struct_time
time.strftime('%D', t)  # 格式化显示，对 time.struct_time 对象进行
```

#### Calendar

```python
import calendar

calendar(y，w=2, l=1, c=6, m=3)  # 返回y年的日历，后边是默认格式
calendar.month(y, m)  # 返回y年m月的日历
calendar.isleap(y)  # 判断y年是否是 闰年
calendar.leapdays(x, y)  # 两个x和y年份之间的闰年数量，区间：[起始， 结束]
```

#### Datetime

```python
import time
import datetime
from datetime import date

datetime.datetime.now()  # 当前时间2022-01-07 10:44:00.357475
date(y, m, d)  # 创建对象(年-月-日)
date.today()  # 创建对象(今天的年月日)
date.fromtimestamp(time.time())  # 用时间戳创建对象(今天的年月日)
d1 = date.today()  # d1是对象
d1.isocalendar()  # 日历显示，(年, 第几周, 星期几)
d1.isoweekday()  # 获取星期，标准格式1~7
d1.weekday()  # 获取星期，格式0~6
d1.year, d1.month, d1.day  # 提取单独的年月日
d1.timetuple()  # 转换为time.struct_time对象
d1.isoformat()  # 标准格式显示(y-m-d)
d1.strftime('%Y-%m-%d %H:%M:%S')  # 格式化显示
datetime.timestamp(d1)  # 转成时间戳
```

#### Timedelta

```python
from datetime import timedelta, datetime

td = timedelta(seconds=3600)  # 时间差
td.days  # 提取天数
td.seconds  # 提取秒数(天以外的秒数)
td.total_seconds()  # 总共的秒数
```

### 文件操作：

#### 文件管理：

```python
open(file, mode)  # 打开文件, mode打开模式
close(file)  # 关闭文件
with  # 操作文件后，保证文件关闭
    r  # 只读(不存在报错)；		w  # 只写(不存在创建，存在清空)；	a  # 追加(不存在创建，存在不清空)
    r+  # r强化版(可以读写)；	w+  # w强化版(可以读写)；			a+  # a强化版(可以读写)
readbble(file)  # 判断文件是否可读
writable(file)  # 判断文件是否可写
read(size)  # 读取指定size长度内容，默认读全部
readline()  # 读取整行内容，包括'\n'字符
write()  # 写操作
tell(file)  # 获取文件操作位置
remove(file)  # 删除文件
```

##### Shutil

```python
import shutil

shutil.copy(old,new)  # 拷贝文件(old只能是文件，new可以是文件可以是目录)
shutil.copyfile(old,new)  # 拷贝文件，只能是文件
shutil.copytree(old,new)  # 拷贝目录，只能时目录，且new不能存在
os.rmdir('test')  # 删除空目录
shutil.rmtree()  # 递归删除目录(空目录，有内容都可以删)
os.rename(old,new)  # 重命名目录(文件)
shutil.move(old,new)  # 移动目录(文件)
```

##### Bytes

```
encode('utf-8')：编码
decode('utf-8')：解码
```

#### 目录管理

##### Os 模块

```python
import os

os.name  # 判断正在使用的平台 (windows 返回 'nt'; Linux 返回'posix')
os.system(cls)  # 清屏
os.system(calc)  # 调出计算器
os.environ[path]  # 获取环境变量
os.getenv(pathxx)  # 从环境中取字符串,获取环境变量的值
os.getpid()  # 获取当前进程id号
os.getpid()  # 获取当前进程的父进程id号
os.getcwd()  # 查看当前目录
os.mkdir(path)  # 新建目录
os.makedirs(a/b/c)  # 创建多级目录(可创建中间目录)
os.rmdir(path)  # 删除空目录
os.removedirs(path)  # 删除多层目录
os.remove(file)  # 删除文件
os.rename(test, test2)  # 重命名文件(目录)
os.stat(file)  # 查看文件信息
os.listdir(path)  # 遍历目录，返回指定路径下的文件和文件夹列表
os.getcwd()  # 查看当前工作目录
os.listdir(os.getcwd())  # 查看指定文件内容
os.walk(path)  # 生成目录树下的所有文件名
os.chdir()  # 改变目录
```

##### Os.path模块

import os

```python
# import os

os.path.join(path, file)  # 目录拼接
os.path.dirname(path)  # 去掉文件名，返回目录路径
os.path.basename(path)  # 去掉目录路径，返回文件名
os.path.split(path)  # 切割路径和文件名；	dir, file = os.path.split(path)
os.path.splitext(path)  # 切割路径和后缀
os.path.exists(file)  # 判断文件(目录)是否存在
os.path.isdir(path)  # 是否是目录
os.path.isfile(path)  # 是否是文件
os.path.isabs(path)  # 是否是绝对路径
os.path.abspath(path)  # 转换为绝对路径
os.path.getsize(file)  # 获取文件大小(只适用于文件，不适用目录)
```



### 正则表达式

#### 相关函数

```python
import re

s = "www.findlp com"
p = ".([a-z]+) "

re.compile(p)  # 创建正则表达式对象，可以让创建正则对象和内容匹配分开操作
re.match(p, s)  # 从开头进行匹配，找到返回对象结果，没有返回None
re.search(p, s)  # 从任意位置匹配，作用同 match
re.findall(p, s)  # 全部匹配，返回所有匹配到的结果列表，没有则返回空列表，添加 () 后，结果只显示 () 匹配的内容
.span()  # 返回匹配内容的位置
.group()  # 返回匹配内容、
.groups()  # 返回所有组的信息，正则需要()
.groupdict()  # 返回分组的字典，键是组的名字，值是组的内容
```

#### 正则语法

###### 单个字符

[abc]：abc的任意一个字符

[0-9]：任意数字字符

[a-zA-Z]：任意字母

[^0-9]：非数字字符

. ：除'\n'以外的任意字符

###### 单个字符

'\d'：匹配数字字符，等价[0-9]

'\D'：匹配非数字字符

'\w'：匹配字(数字、字母、下划线、汉字)

'\W'：匹配非字(< >|、)

'\s'：匹配空白字符(\n, \r, \t、空格)

'\S'：匹配非空白字符

'\b'：匹配词边界(开头、结尾、空格、标点)

'\B'：匹配非词边界

###### 次数限定

*：匹配0次或任意次

+：匹配最少一次

?：匹配零次或一次，非贪婪匹配

?: ：非匹配获取，匹配冒号后的内容，但不获取匹配结果，不进行存储供以后使用

{m}：指定m次

{m,n}：指定m~n次

{m,}：最少m次

{,m}最多m次

###### 边界限定

^：以指定内容开头

$：以指定内容结尾

###### 分组

<div></div>：固定匹配
<[a-z]+></[a-z]+>：动态匹配：匹配多次嵌套的标签

<[a-z]+)></(\1)>：无名分组：\1、\2分别表示前面的第一组、第二组匹配的内容

(?P<one>[a-z]+)  ；?P=one：给标签起名；相对应

###### 匹配模式

re.I ：表示忽略大小写

re.M ：多行处理(默认会把字符串当作一行处理)

re.S ：单行处理，是.可以匹配任意(忽略\n)

###### 字符替换

re.sub("old_str", "new_str", text, 2) ：最多替换2次，默认全部

### 图片处理

```python
from PIL import Image, ImageDraw, ImageFont

img = Image.open(fp, mode="r")  # 打开图片(图片名.要带后缀)
img.save()  # 保存图片(指定文件名.要带后缀)
img.show()  # 查看图片
Image.new(mode, size, color=0)  # 新建图片('RGB', 尺寸, 颜色)
img.thumbnail(size)  # 修改尺寸，在原图修改
img.resize(size)  # 修改尺寸，生成新的图片
draw = ImageDraw.Draw(img)  # 创建画笔
font = ImageFont.truetype(font, size=10)  # 创建字体
draw.point(xy, fill)  # 画点，一个像素(位置，颜色)
draw.line(xy, fill, width=0)  # 画线(位置*n，颜色，宽度)
draw.text(xy, text, fill, font)  # 画字(位置，字，颜色，字体)
```

### 进程线程协程

#### 多进程

multiprocessing

- 进程是最小的资源管理单元，独立运行，一个程序就是一个进程
  - 优点：利用cpu多核
  - 缺点：占用资源多；启动数目有限
  - 适用：CPU密集型计算

#### 多线程

threading

- 线程是最小的执行单元
- 一个程序至少一个主线程，可以开多个线程，线程之间数据共享
- 资源分配给进程，cpu分配给线程，真正在cpu上运行的是线程
  - 优点：比进程更轻量；占用资源少
  - 缺点：
    - 相比进程：多线程只能并发，因为GIL的存在不能利用cpu多核
    - 相比协程：启动数目有限；占用内存资源；有线程切换开销
  - 适用：IO密集型计算；同时运行的任务数目要求不多

```python
import threading
import time


def main(n):
    print("task:", n)
    while n >= 0:
        time.sleep(1)
        print(n, "s")
        n -= 1


if __name__ == "__main__":
    t1 = threading.Thread(target=main, args=(3,))
    t2 = threading.Thread(target=main, args=(4,))
    t1.start()
    t2.start()

```

**多线程+queue队列**

```python
import threading
from queue import Queue


def parse(input_queue: Queue, output_queue: Queue):
    while output_queue.qsize() < 1000:
        num = input_queue.get()
        output_queue.put(num + 1)
        print(f'输出成功, 目前 {output_queue.qsize()}')


if __name__ == "__main__":
    print('start')
    base_url = 'https://www.cnbolgs.com/#p'
    input_queue = Queue()
    output_queue = Queue()

    thread_list = []

    for i in range(10000):
        input_queue.put(1)
    for i in range(3):
        t = threading.Thread(target=parse, args=(input_queue, output_queue))
        t.start()
        thread_list.append(t)
    for t in thread_list:
        t.join()
    print('end')
```



#### 多协程

asyncio

- 一个线程可有多个协程
  - 优点：内存开销最少；启动数量最多
  - 缺点：支持的库有限（aiohttp vs requests）；代码实现复杂
  - 适用：IO密集型计算；需要超多任务运行；代码复杂度能接受

```

```

## 虚拟环境

#### 安装工具

```sh
pip install virtualenvwrapper  # linux
pip install virtualenvwrapper-win  # windows cmd
pip install virtualenvwrapper-powershell # windows powershell
```

#### 命令

```sh
# 查看虚拟环境列表
workon
lsvirtualenv

# 创建虚拟环境
mkvirtualenv -p python3 env-name
# 删除虚拟环境
rmvirtualenv env-name

# 激活虚拟环境
workon env-name
# 推出虚拟环境
deactivate
```

#### Powershell

**powershell 无法使用 workon 切换虚拟环境**

- 临时解决

```sh
& cmd /k workon <envname>
```

- 永久配置

在 C:\Users\xxx\Documents\WindowsPowerShell 下新建 Microsoft.PowerShell_profile.ps1文件

添加以下内容

```
function workon($environment) {
  & cmd /k workon.bat $environment
}
```

## Anaconda

```sh
# 查看版本
conda -V
# 列出所有虚拟环境
conda-env list
conda info -e
# 更新conda
conda update
# 初始化conda与shell的交互
conda init
```

#### 包管理

```sh
# 列出已安装包
conda list
```

##### 安装包

```sh
conda install package_name
# 指定环境安装包
conda install -n env_name package_name
```

##### 删除包

```sh
conda remove package_name
# 指定环境删除包
conda remove -n env_name package_name
```

#### 虚拟环境

##### 新建环境

- 默认创建在conda目录下的envs文件目录下

```sh
conda create -n env_name python=3.6.2
# 新建环境，同时安装需要的包
conda create -n env_name numpy matplotlib python=3.6.2
# 安装打包的环境
conda env_name create -f environment.yml
```

##### 激活环境

```sh
# Linux
source activate env_name
# Windows
activate env_name
```

##### 退出环境

```sh
# Linux
sourve deactivate
# Windows
deactivate
```

##### 删除环境

```sh
conda remove -n env_name --all
```

##### 复制环境

```sh
conda cteate -n new_env_name --clone old_env_name
```

##### 环境迁移

```sh
# 打包环境
conda env_name export > environment.yml
# 安装打包的环境
conda env_name create -f environment.yml
```

##### 更新python版本

- 需要在指定环境下运行命令

```sh
# 更新最新版本
conda update python
# 升级指定版本
conda install python==3.6.9
```

