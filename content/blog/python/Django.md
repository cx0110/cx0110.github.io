---
title: "Django 开发指南"
subtitle: "Python Django Web框架实践"
summary: "深入学习Django Web框架，包括项目创建、模型设计、视图开发和部署实践"
authors:
  - admin
tags:
  - Python
  - Django
  - Web框架
  - 后端开发
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

# 项目创建

```bash
# 创建名为 django01的项目
django-admin startproject django01 
# 进入项目目录
cd django01 
# 创建名为 app01的app
django-admin startapp app01 
# 启动django项目，默认127.0.0.1:8000
python manage.py runserver 
# 指定端口启动
python manage.py runserver 8002  
# 创建超级管理员
python manage.py createsuperuser 
```

## Setting.py

**文档：**

https://docs.djangoproject.com/zh-hans/3.2/ref/settings/

### 服务主机

```python
# 安全措施，允许哪些地址访问
DEBUG = True  # 生产环境要禁用

ALLOWED_HOSTS = []  # 默认。DEBUG=True时，根据['.localhost', '127.0.0.1', '[::1]']验证
ALLOWED_HOSTS = ['*']  # 允许所有
ALLOWED_HOSTS = ['127.0.0.1', '192.168.1.10']  # 允许指定ip访问
```

### 注册app

```python
INSTALLED_APPS = [
    ...
    'apps.app01.App01Config',  # 新加
    'apps.user.UserConfig'  # 新加
]
```

### Mysql数据库

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'db_name',
        'USER': 'root',
        'PASSWORD': '123456',
        'HOST': '127.0.0.1',
        'PORT': 3306
    },
    ...
}
```

##### Pymysql

- 推荐使用mysqlclient

```
pip install pymysql
```

settings.py 同级`__init__`.py 

```
import pymysql
pymysql.install_as_MySQLdb()
```

##### Mysqlcilent

```bash
pip install mysqlclient
```

### 缓存

```
pip install django-redis
```

settings.py

```python
CACHES = {
    # 默认
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': '',
        'TIMEOUT': 300,  # 缓存超时时间，单位秒。None：永久不过期
        'OPTIONS': {
            'MAX_ENTRIES': 300,  # 允许缓存最大条目
            'CULL_FREQUENCY': 3, # 缓存条目最大时，删除条目的比例。1：全部；2：1/2；3：1/3
            
        },
    },
    # 附加缓存
    'session': {
        'BACKEND': 'django_redis.cache.RedisCache',  # 缓存redis
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            # 'PASSWORD': ''
        }
    },
    # 购物车
    'cart': {
        'BACKEND': 'django_redis.cache.RedisCache',  # 缓存redis
        'LOCATION': 'redis://127.0.0.1:6379/2',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            # 'PASSWORD': ''
        }
    },
}
```

views.py

```python
from django_redis import get_redis_connection
 
conn = get_redis_connection('cart')
print(conn.hgetall('xxx'))
```

### HTML模板目录

```python
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')]   # 指定html文件所在的位置目录templates
        ,
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]
```

### 语言时区

```python
LANGUAGE_CODE = 'zh-hans'  # 中文显示
TIME_ZONE = 'Asia/Shanghai'  # 设置时区
USE_I18N = True  # 国际化
USE_L10N = True  # admin后台显示时间格式化为 '2020-09-12 12:00:00'
USE_TZ = False  # ORM查询返回，是否自动转换为UTC时间
```

### 静态文件

```python
# 静态文件夹的别名
STATIC_URL = '/static/'
# 所有静态文件（css/js/图片）都放在我下面你配置的文件夹中
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "static"),
]
```

### Session

```python
# 数据库Session（默认）
SESSION_ENGINE = 'django.contrib.sessions.backends.db'   # 存储数据库

# 缓存Session
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'  # 指定缓存存储
SESSION_CACHE_ALIAS = 'default'                            # 使用的缓存别名（默认内存缓存，也可以是memcache），此处别名依赖缓存的设置
 
# 文件Session
SESSION_ENGINE = 'django.contrib.sessions.backends.file'    # 存储文件
SESSION_FILE_PATH = None                                    # 缓存文件路径，如果为None，则使用tempfile模块获取一个临时地址tempfile.gettempdir() 
 
# 缓存+数据库
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'        # 引擎
 
# 加密Cookie Session
SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'   # 引擎
 
# 其他公用设置项：
SESSION_COOKIE_NAME ＝ "sessionid"            # Session的cookie保存在浏览器上时的key，即：sessionid＝随机字符串（默认）
SESSION_COOKIE_PATH ＝ "/"                    # Session的cookie保存的路径。默认 /
SESSION_COOKIE_DOMAIN = None                  # Session的cookie保存的域名。默认 None
SESSION_COOKIE_SECURE = False                 # 是否Https传输cookie。默认 False
SESSION_COOKIE_HTTPONLY = True                # 是否Session的cookie只支持http传输。默认 True
SESSION_COOKIE_AGE = 1209600                  # session的cookie失效日期，单位秒，默认2周
SESSION_EXPIRE_AT_BROWSER_CLOSE = False       # 是否关闭浏览器使得Session过期。默认
SESSION_SAVE_EVERY_REQUEST = False            # 是否每次请求都保存Session，默认修改之后才保存。默认
```

### 日志

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message} ',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'sql': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, "logs/sql.log"),
            'formatter': 'verbose'
        },
        'error': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, "logs/error.log"),
            'formatter': 'verbose'
        },
    },
    'loggers': {
        'django': {
            'handlers': ['error'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'error': {
            'handlers': ['error'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'django.db.backends': {
            'handlers': ['sql'],
            'level': 'DEBUG',
            'propagate': True,
        },
    },
}
```

## Simpleui 后台

官网教程：https://simpleui.72wo.com/docs/simpleui/doc.html

```sh
pip install django-simpleui
```

settings.py 加入

```python
INSTALLED_APPS = [
    'simpleui',
    ...
]
```

## 环境打包

```bash
# 打包环境
pip freeze > requirements.txt
# 下载环境
pip install -r requirements.txt
```

## Model 模型

- 文档：https://docs.djangoproject.com/zh-hans/3.2/ref/models/fields/

```python
class Author(models.Model):
    GENDERS = (
        (0, '男'),
        (1, '女')
    )
    name = models.CharField(max_length=20, verbose_name='名字', db_column='name')
    gender = models.IntegerField(default=0, choices=GENDERS, verbose_name='性别')
    created = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    deleted = models.IntegerField(default=0, verbose_name='逻辑删除')

    class Meta:
        # managed = False
        db_table = 'author'
        app_label = 'demo'

    # 逻辑删除
    def delete(self, using=None, keep_parents=False):
        self.deleted = 1
        self.save()
        
        
class Book(models.Model):
    name = models.CharField(max_length=30, default='', verbose_name='书名')
    author = models.ForeignKey(Author, on_delete=models.CASCADE, db_constraint=False, related_name='作者')  # db_constraint=False：逻辑外键。数据库不使用外键，仅django内部使用
    price = models.IntegerField(default=0, verbose_name='价格')
    seq = models.IntegerField(default=0, verbose_name='顺序')
    created = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    deleted = models.IntegerField(default=0, verbose_name='逻辑删除')

    class Meta:
        # managed = False
        db_table = 'book'
        app_label = 'demo'
```

#### 索引

```python
class Meta:
    # 索引
    indexes = [
        models.Index(fields=['project']),
    ]
        
    # 联合索引
    index_together = [["pub_date", "deadline"]]
	# index_together = ["pub_date", "deadline"]  # 单字段可以一个列表 

    # 联合唯一索引
    unique_together = [['driver', 'restaurant']]  
    # unique_together = ['driver', 'restaurant']
```

#### DateTimeField

精度默认为 6，修改为0 需要将相对配置 datetime(6) 改为 datetime

```python
## settings.py
from django.db.backends.mysql.base import DatabaseWrapper
DatabaseWrapper.data_types['DateTimeField'] = 'datetime'
```

#### 模型逆向生成

```python
python manage.py inspectdb > apps/models.py
# 指定表生成
python manage.py inspectdb tb > apps/models.py
```

#### 清理migrations

```python
python manage.py makemigrations	# 确保 migration文件和数据库同步
python manage.py showmigrations	# 看文件是否都迁移成功。[X]表示迁移成功
python manage.py migrate --fake app名 zero  # 清除迁移历史记录
python manage.py makemigrations  # 再次生成迁移文件
python manage.py migrate --fake-initial  # 执行迁移，但不会真的执行
```



## 多数据库

**settings.py**

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '',
        'USER': '',
        'PASSWORD': '',
        'HOST': 'localhost',
        'PORT': 3306
    },
    'db02': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '',
        'USER': '',
        'PASSWORD': '',
        'HOST': 'localhost',
        'PORT': 3306
    }
}
# 数据库路由文件地址
DATABASE_ROUTERS = ['fresh.database_router.DatabaseAppsRouter']
# 配置app对应的路由表
DATABASE_APPS_MAPPING = {
    'app01': 'default',
    'app02': 'db02',
    'app03': 'db02',
}
```

**创建数据库路由规则**

```python
from django.conf import settings

DATABASE_MAPPING = settings.DATABASE_APPS_MAPPING


class DatabaseAppsRouter:
    """
    A router to control all database operations on models for different
    databases.
    In case an app is not set in settings.DATABASE_APPS_MAPPING, the router
    will fallback to the `default` database.
    Settings example:
    DATABASE_APPS_MAPPING = {'app1': 'db1', 'app2': 'db2'}
    """

    def db_for_read(self, model, **hints):
        """"Point all read operations to the specific database."""
        if model._meta.app_label in DATABASE_MAPPING:
            return DATABASE_MAPPING[model._meta.app_label]
        return None

    def db_for_write(self, model, **hints):
        """Point all write operations to the specific database."""
        if model._meta.app_label in DATABASE_MAPPING:
            return DATABASE_MAPPING[model._meta.app_label]
        return None

    def allow_relation(self, obj1, obj2, **hints):
        """Allow any relation between apps that use the same database."""
        db_obj1 = DATABASE_MAPPING.get(obj1._meta.app_label)
        db_obj2 = DATABASE_MAPPING.get(obj2._meta.app_label)
        if db_obj1 and db_obj2:
            if db_obj1 == db_obj2:
                return True
            else:
                return False
        return None

    def allow_syncdb(self, db, model):
        """Make sure that apps only appear in the related database."""
        if db in DATABASE_MAPPING.values():
            return DATABASE_MAPPING.get(model._meta.app_label) == db
        elif model._meta.app_label in DATABASE_MAPPING:
            return False
        return None

    def allow_migrate(self, db, app_label, model=None, **hints):
        """
        Make sure the auth app only appears in the 'auth_db'
        database.
        """
        if db in DATABASE_MAPPING.values():
            return DATABASE_MAPPING.get(app_label) == db
        elif app_label in DATABASE_MAPPING:
            return False
        return None
```

**创建model**

```python
from django.db import models


class Author(models.Model):
    name = models.CharField(max_length=20)
    created = models.DateTimeField()
    updated = models.DateTimeField()
    deleted = models.IntegerField()

    class Meta:
        db_table = 'author'
        app_label = 'demo'
```

**生成数据表**

```python
python manage.py makemigrations
python manage.py migrate --database=db02
```

## 跨域解决

#### 方案一：禁用跨域校验（开发模式可以用）

```python
MIDDLEWARE = [
    # 'django.middleware.csrf.CsrfViewMiddleware',  # 注释这行，会允许所有跨域请求
]
```

#### 方案二：cors扩展（推荐）

```sh
pip install django-cors-headers
```

**setting.py**

```python
# 配置应用
INSTALLED_APPS = [
    ...
    'corsheaders',
    ...
]
# 中间层设置
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # 注意顺序放首位
    ...
]
CORS_ALLOW_CREDENTIALS = True # 允许携带cookie
# CORS_ORIGIN_ALLOW_ALL = True # 允许所有主机跨域
# 允许跨域白名单
CORS_ORIGIN_WHITELIST = (
    '127.0.0.1:8080',
    ...
)
# 允许跨域请求方法
CORS_ALLOW_METHODS = (
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'OPTIONS',
    'VIEW',
)
# 允许跨域请求头
CORS_ALLOW_HEADERS = (
    'XMLHttpRequest',
    'X_FILENAME',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'Pragma',
)
```

## Session 会话

**全局配置**

```python
# setting.py

# 缓存session
CACHES = {
    ...
    'session': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            # 'PASSWORD': ''
        }
    }
}

# Session配置
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'  # 指定redis存储
SESSION_CACHE_ALIAS = 'session'  # 使用的缓存别名
SESSION_COOKIE_AGE = 30  # 过期时间，单位秒。默认2周

REST_FRAMEWORK = {
    # 自定义认证
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'utils.custom_authentication.CustomJWTAuth',
    ),
}
```

### 命令

```python
request.session.session_key  # 获取sessionid
request.session.exists('sessionid')  # 判断获取sessionid是否存在

request.session['key'] = 'value'  # 设置session
request.session.setdefault('key', 'value')  # 不存在则设置
request.session.get('key')  # 获取session，默认None
del request.session['key']  # 删除session指定键值对
request.session.delete()  # 删除当前会话数据和数据库数据
request.session.clear()  # 清除session，删除存储session值
request.session.flush()  # 清除session，删除当前会话cookie和存储session（常用）

request.session.keys()  # 获取所有键
request.session.values()  # 获取所有值
request.session.items()  # 获取所有键值对
request.session.iterkeys()  # 
request.session.itervalues()  #
request.session.iteritems()  # 

request.session.clear_expired()  # 删除所有失效日期小于当前日期的session

request.session.set_expiry(value)  # 设置session、cookie有效期
								# 整数：指定秒后过期；
    							# datatime或timedelta：指定时间过期；
        						# 0：用户关闭浏览器时过期
```

## Redis

```python

```

## Transaction 事务

```python
from django.db import transaction


# 装饰器用法
@transaction.atomic
def func(request):
    # 函数下所有代码会在一个事务中执行
    pass


# with用法，更灵活
def func(request):
    # 这部分代码不在事务中，会被 Django 自动提交
    pass

    with transaction.atomic():
        # 这部分代码会在事务中执行

        s1 = transaction.savepoint()  # 设置保存点，可设置多个

        transaction.savepoint_rollback(s1)  # 事务回滚至指定保存点

        transaction.savepoint_commit(s1)  # 提交事务

        pass
```

## ORM

### 查询条件

```sh
# 使用方式，字段__条件

exact  # 精准 =
iexact  # 精准 =，忽略大小写
contains  # 包含
icontains  # 包含，忽略大小写
in  # 在容器中
gt  # 大于 >
gte  # 大于等于 >=
lt  # 小于 <
lte  # 小于等于 <=
startswith  # 字段以给定值开始
istartswith  # 字段以给定值开始，忽略大小写
endswith  # 字段以给定值结束
iendswith  # 字段以给定值结束，忽略大小写
range  # 用于指定容器范围，并查询容器范围的数据
date  # 针对某些date或者datetime类型的字段，根据date部分进行过滤(年月日)
time  # 根据时间来进行查询：比较日期时间(datetime)字段的时间部分
year  # 根据年份进行查询
isnull  # 对应SQL语句中的IS NULL和IS NOT NULL，可接受参数为True和False
regex  # 根据指定的正则表达式来查询
iregex  # 根据指定的正则表达式来查询，忽略大小写
```

#### 排序

```python
from django.db.models import F
# name字段为null的，排最前面
.order_by(F('name').asc(nulls_first=True), 'create_time')
# name字段为null的，排最后边
.order_by(F('name').asc(nulls_last=True), 'create_time')
```



```python
# 查不到返回404
get_object_or_404()
```



## DRF 框架

### 安装DRF

```
pip install djangorestframework  # drf框架
pip install django-filter # 过滤器
```

**setting.py 配置**

```PYTHON
INSTALLED_APPS = [
	...
    'rest_framework',
    'django_filters',
    
    'apps.book',
    ...
]
...
REST_FRAMEWORK = {
    # 返回时间格式
    'DATETIME_FORMAT': "%Y-%m-%d %H:%M:%S",
    # 自定义异常响应格式
    'EXCEPTION_HANDLER': 'utils.custom_exception.custom_exception_handler',
    # # 认证
    # 'DEFAULT_AUTHENTICATION_CLASSES': (
    #     'rest_framework.authentication.BasicAuthentication',
    #     'rest_framework.authentication.SessionAuthentication',
    # ),
    # # 权限
    # 'DEFAULT_PERMISSION_CLASSES': (
    #     'rest_framework.permissions.IsAuthenticated',
    # ),
    # 限流
    'DEFAULT_THROTTLE_CLASSES': (
        'rest_framework.throttling.AnonRateThrottle',  # 游客
        'rest_framework.throttling.UserRateThrottle'  # 用户
    ),
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '10/second'
    },
    # 过滤
    'DEFAULT_FILTER_BACKENDS': ('django_filters.rest_framework.DjangoFilterBackend',)
}
```

### DRF的基本使用

**models.py**

```python
from django.db import models


class Author(models.Model):
    GENDERS = (
        (0, '男'),
        (1, '女')
    )
    name = models.CharField(max_length=20, verbose_name='名字')
    gender = models.IntegerField(default=0, choices=GENDERS, verbose_name='性别')
    created = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    deleted = models.IntegerField(default=0, verbose_name='逻辑删除')

    class Meta:
        # managed = False
        db_table = 'author'

    # 逻辑删除
    def delete(self, using=None, keep_parents=False):
        self.deleted = 1
        self.save()


class Book(models.Model):
    name = models.CharField(max_length=30, default='', verbose_name='书名')
    author = models.ForeignKey(Author, on_delete=models.CASCADE, db_constraint=False,
                               related_name='作者')  # db_constraint=False：数据库不使用外键，仅django内部使用
    price = models.IntegerField(default=0, verbose_name='价格')
    seq = models.IntegerField(default=0, verbose_name='顺序')
    created = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated = models.DateTimeField(auto_now=True, verbose_name='更新时间')
    deleted = models.IntegerField(default=0, verbose_name='逻辑删除')

    class Meta:
        # managed = False
        db_table = 'book'
```

**urls.py**

```python
from django.urls import path
from rest_framework import routers
from apps.book.views import BookView

urlpatterns = [
    # path('books', BookView.as_view({'get': 'list'})),
]

# trailing_slash为False，url不自动添加尾斜杠
router = routers.SimpleRouter(trailing_slash=False)
router.register(r'author', AuthorView, basename='author')
router.register(r'book', BookView2, basename='book')

urlpatterns += router.urls
```

**serializer.py**

```python
from rest_framework import serializers

from apps.demo.models import Book, Author


class AuthorSerializer(serializers.ModelSerializer):
    gender = serializers.CharField(source='get_gender_display', read_only=True, required=False)

    class Meta:
        model = Author
        fields = '__all__'  # 返回字段，__all__ 代表所有


class BookSerializer(serializers.ModelSerializer):
    """
    read_only：只在查询时有效
    write_only：只在写入时有效
    """
    author = serializers.CharField(label='作者', source='author_id.name', read_only=True)
    # author_id = serializers.PrimaryKeyRelatedField(label='作者', read_only=True)

    class Meta:
        model = Book
        fields = '__all__'  # 返回字段，__all__ 代表所有
```

**views.py**

```python
class AuthorView(ModelViewSet):
    """
    新增：POST /author
    删除：DELETE /author/1
    修改：PATCH /author/1
    作者列表查询：GET /author
    作者图书查询：GET /author/{pk}/book
    """
    queryset = Author.objects.filter(deleted=0)
    serializer_class = AuthorSerializer

    @action(methods=['get'], detail=True, serializer_class=BookSerializer)
    def book(self, request, pk=None, *args, **kwargs):
        self.queryset = Book.objects.filter(deleted=0, author=pk)
        return self.list(self, request, *args, **kwargs)


class BookView(APIView):
    """
    新增：POST /book
    """

    def post(self, request, *args, **kwargs):
        # 创建或更新
        name = request.data.pop('name')
        res, created = Book.objects.update_or_create(defaults=request.data, name=name)
        ser = BookSerializer(res)
        return Response(ser.data)
```

### Serializer.py 序列化器

**序列化：**对查询结果处理

**反序列化：**对接收参数处理

```python
from rest_framework import serializers
from apps.book.models import Book

class BookSerializer(serializers.ModelSerializer):
    """
    read_only：只在查询时有效
    write_only：只在写入时有效
    """
    name = serializers.CharField(max_length=30)
    author = serializers.CharField(max_length=30)
    price = serializers.IntegerField(required=False)
    seq = serializers.IntegerField(required=False)
    author = serializers.CharField(read_only=True, source='author.name')  # 序列化外键字段

    class Meta:
        model = Book
        fields = '__all__'  # 返回字段，__all__ 代表所有
        exclude = ('seq',)  # 除了seq 字段，其他都序列化
        # 指定字段说明
        extra_kwargs = {
            'name': {'write_only': True},
            'author': {'write_only': True},
            'price': {'write_only': True}
        }
        
    # 改变序列输出行为
    def to_representation(self, instance):
        ret = super().to_representation(instance)
        # json字符串 => 字典
        if 'field' in ret:
            try:
                ret['field'] = json.loads(ret['field'])
            except ValueError:
                pass
        return ret
```

**view.py**

```python
class BookView(APIView):
    def post(self, request, *args, **kwargs):
        # 创建或更新
        name = request.data.pop('name')
        res, created = Book.objects.update_or_create(defaults=request.data, name=name)
        ser = BookSerializer(res)
        return Response(ser.data)
    
  BookSerializer(res, many)
```

#### 嵌套序列化

```python
## models.py
from django.db import models


class Author(models.Model):
    name = models.CharField(max_length=20)

    class Meta:
        # managed = False
        db_table = 'author'
        app_label = 'demo'


class Book(models.Model):
    name = models.CharField(max_length=30)
    author = models.ForeignKey(Author, on_delete=models.CASCADE, related_name='books', db_constraint=False)  # db_constraint=False：数据库不使用外键，仅django内部使用

    class Meta:
        # managed = False
        db_table = 'book'
        app_label = 'demo'
```

##### 常规嵌套

```python
# 书籍嵌套作者
class AuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Author
        fields = '__all__'

class BookSerializer(serializers.ModelSerializer):
    author = AuthorSerializer(read_only=True, source='author')
    class Meta:
        model = Book
        fields = '__all__'

# 作者嵌套书籍
class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = '__all__'
        
class AuthorSerializer(serializers.ModelSerializer):
    books = AuthorSerializer(read_only=True, source='books'， many=True)
    class Meta:
        model = Author
        fields = '__all__'
```

##### 从下往上查

```python
## serializer.py
from rest_framework import serializers

# 底层往上查
class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = '__all__'
        depth = 2  # 递归深度
```

##### 从上往下查

```python
## serializer.py
from rest_framework import serializers
        
class BookSerializer(serializers.ModelSerializer):
    # 多对一序列化。author_id：外键字段名
    author = serializers.CharField(label='作者', source='author_id.name', read_only=True)
    #image_list = ProductImageSerializer(source='product_info', read_only=True, many=True)

    class Meta:
        model = Book
        fields = '__all__'
```

##### 多级嵌套

```python
## models.py
class Area(models.Model):
    p_id = models.ForeignKey('self', db_column='p_id', db_constraint=False, on_delete=models.SET_DEFAULT, default=0, verbose_name='地区', related_name='children')
    name = models.CharField(max_length=50, verbose_name='地区名')

    class Meta:
        db_table = 'area'
        

## serializer.py
from rest_framework import serializers


class AreaSerializer3(serializers.ModelSerializer):
    class Meta:
        model = Area
        fields = '__all__'

class AreaSerializer2(serializers.ModelSerializer):
    children = AreaSerializer3(many=True, read_only=True)

    class Meta:
        model = Area
        fields = '__all__'

class AreaSerializer(serializers.ModelSerializer):
    children = AreaSerializer2(many=True, read_only=True)

    class Meta:
        model = Area
        fields = '__all__'

        
## views.py
from rest_framework import mixins
from rest_framework.viewsets import GenericViewSet

class AreaView(GenericViewSet, mixins.ListModelMixin):
    queryset = Area.objects.filter(pid=0)
    serializer_class = AreaSerializer
```

##### 递归嵌套

```python
## models.py
class Area(models.Model):
    p_id = models.ForeignKey('self', null=True, db_column='p_id', db_constraint=False, on_delete=models.CASCADE, verbose_name='地区')
    name = models.CharField(max_length=50, verbose_name='地区名')

    class Meta:
        db_table = 'area'

        
## serializer.py
from rest_framework import serializers

class AreaSerializer(serializers.ModelSerializer):
    children = serializers.SerializerMethodField()

    class Meta:
        model = Area
        fields = '__all__'
        
    def get_children(self, obj)
        res = Area.objects.filter(p_id=obj.id)
        return AreaSerializer(res, many=True).data

    
## views.py
from rest_framework import mixins
from rest_framework.viewsets import GenericViewSet

class AreaView(GenericViewSet, mixins.ListModelMixin):
    queryset = Area.objects.filter(pid=None)
    serializer_class = AreaSerializer
```

#### ChoiceDield

```python
class User(models.Model):
    GENDERS = (
        (0, '男'),
        (1, '女'),
    )
    gender = models.IntegerField(default=0, choices=GENDERS)
    

class UserSerializer(serializers.ModelSerializer):
    # 使用 get_<字段名>_display的方法
    gender = serializers.CharField(source='get_gender_display', required=False)
    
    class Meta:
        model = User
        fields = '__all__'
```

#### 获取数据

```python
## views.py
# 传参
self.kwargs['user_id'] = 123

## serializer.py
# 取参
self.context.get('view').kwargs
```

#### 序列化器调用

```python
# 创建
ser = BookSerializer(data)
if ser.is_valid():
    ser.save()
    
# 更新
instance = Book.objects.filter(id=1).first()
ser = BookSerializer(instance, data)
# ser = BookSerializer(instance=instance, data=data, partial=True)  # 部分更新
if ser.is_valid():
    ser.save()

```



#### 重写方法

```python
##views.py
class OrderView(GenericAPIView, mixins.CreateModelMixin):
    authentication_classes = [FreshSessionAuth]
    queryset = OrderMaster.objects.filter(deleted=0)
    serializer_class = OrderMasterSerializer

    def post(self, request, *args, **kwargs):
        self.kwargs['user_id'] = 123
        return self.create(request, *args, **kwargs)

##serializer.py
class OrderMasterSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderMaster
        fields = '__all__'

    def create(self, validated_data):
        user_id = self.context.get('view').kwargs.get('user_id')
        validated_data['user_id'] = user_id
        return super().create(validated_data)
        # return OrderMaster.objects.create(**validated_data)
    
    def update(self, instance, validated_data):
        if validated_data.get('pay_state') == 1:
            validated_data['order_state'] = 1
            
        super().update(instance, validated_data)
        return instance
```

### Filters.py 过滤器

```python
## filters.py

from django_filters import filters
from django_filters.rest_framework import FilterSet
from apps.book.models import Book

class BookFilter(FilterSet):
    """
    field_name：指定字段，默认同名
    lookup_expr：匹配方式，orm同款
    """
    name = filters.CharFilter(field_name='name', lookup_expr='icontains')

    class Meta:
        model = Book
        fields = ['is_delete', 'name']  # 过滤条件, 精准匹配
        # or
        fields = {
            'is_delete': ['exact', 'contains'],
            'name': ['exact', 'contains'],
        }
```

### Pages.py 分页器

```python
from rest_framework.pagination import PageNumberPagination

class LargePagination(PageNumberPagination):
    page_size = 100  # 每页显示数量
    page_size_query_param = 'page_size'  # 分页控件的查询参数的名称
    max_page_size = 10000  # 允许的最大页面大小。该属性仅在 page_size_query_param 也被设置时有效


class StandardPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 1000
```

### APIView类视图

```python
from rest_framework.views import APIView

class BookView(APIView):
    renderer_classes = []  # 自定义过滤器
    authentication_classes = []  # 自定义认证
    throttle_classes = []  # 自定义限流
    permission_classes = []  # 自定义权限
    
    def get(self, request):
        pass
        
    def post(self, request):
        pass
```

### ModelViewSet 视图集

```python
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.viewsets import ModelViewSet

from apps.book.models import Book
from apps.book.filters import BookFilter
from apps.book.pages import LargeSetPagination
from apps.book.serializers import BookSerializer

class BookView(ModelViewSet):
    # renderer_classes = []  # 自定义过滤器
    # authentication_classes = []  # 自定义认证
    # throttle_classes = []  # 自定义限流
    # permission_classes = []  # 自定义权限
    # http_method_names = ['get', 'post',] # 允许请求方式

    queryset = Book.objects.all()
    serializer_class = BookSerializer
    # pagination_class = LargeSetPagination  # 自定义分页器

    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]

    # 过滤方案一 filter_class 自定义高级过滤规则
    # filter_class = BookFilter  # 与filter_fields相斥，需配置DjangoFilterBackend

    # 过滤方案二 filter_fields 精准查询
    # filter_backends = [DjangoFilterBackend]  # 全局配置过滤器后 无需配置此项
    filter_fields = ['name']  # url中关键字结合列表内字段各自精准匹配

    # 过滤 模糊查询
    # filter_backends = [SearchFilter]  # 设置过滤后端
    search_fields = ['name', 'Author__name']  # url中的关键字为search，列表内所有字段内做模糊匹配。匹配外键字段是需写：外键名__外键字段

    # # 排序
    # filter_backends = [OrderingFilter]  # 设置排序后端
    ordering_fields = ['seq', 'id']  # 可排序字段，倒序需在url参数后字段前面加 -
    ordering = ['seq']  # 默认排序

    # 分页
    # pagination_class = None  # 关闭分页。全局配置后进行关闭
    def retrieve(self, request, *args, **kwargs):
        print('retrieve')
        return super().retrieve(request, *args, **kwargs)

    def list(self, request, *args, **kwargs):
        print('list')
        return super().list(request, *args, **kwargs)
    
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
```

请求示例：

```
http://127.0.0.1/book?search=王子
http://127.0.0.1/book?name=小王子&is_delete=0
http://127.0.0.1/book?ordering=seq,-id 
```

### 批量创建

```python
class BookView(ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    http_method_names = ['post',]
    
    def get_serializer(self, *args, **kwargs):
        if 'data' in kwargs:
            if isinstance(kwargs['data'], list):
                kwargs['many'] = True

        return super().get_serializer(*args, **kwargs)
```

### 自定义路由

**urls.py**

```python
urlpatterns = [
    # 额外行为，单独定义路由。或使用 @action注册配合路由器自动生成
    # path('books/latest', BookView.as_view({'get': 'latest'})),
]

router = routers.SimpleRouter(trailing_slash=False)
router.register(r'books', BookView)
urlpatterns += router.urls
```

**views.py**

```python
from rest_framework.decorators import action
from rest_framework.viewsets import ModelViewSet

class BookView(ModelViewSet):
    queryset = Book.objects.filter(is_delete=0)
    serializer_class = BookSerializer
    
    @action(methods=['get'], detail=False)  # 使路由器自动生成该路由。detail=False表示不需要pk
    def latest(self, request, *args, **kwargs):
        book = Book.objects.latest('id')
        ser = self.get_serializer(book)
        return Response(ser.data)
    
    
    @action(methods=['get'], detail=True)  # 使路由器自动生成该路由。detail=True表示需要pk，路由为 books/{pk}/lastst
    def latest(self, request, *args, **kwargs):
        pk = kwargs['pk']
        book = Book.objects.latest('id')
        ser = self.get_serializer(book)
        return Response(ser.data)
```

### 版本控制

**全局配置**

```python
## settings.py
REST_FRAMEWORK = {
    'DEFAULT_VERSIONING_CLASS': 'rest_framework.versioning.NamespaceVersioning',
    'DEFAULT_VERSION': 'v1',  # 默认版本(从request对象里取不到，显示的默认值)
    'ALLOWED_VERSIONS': ['v1', 'v2'],  # 允许的版本，与接口文档冲突
    'VERSION_PARAM': 'version'  # URL中获取值的key
}

## urls.py
path(r'v1/api/', include(('apps.urls', "apps"), namespace="v1")),
path(r'v2/api/', include(('apps.urls', "apps"), namespace="v2")),
```

### 自定义异常类响应码

**custom_exceptions.py**

```python
from django.utils.translation import gettext_lazy as _
from rest_framework.exceptions import APIException

class HaveExisted(APIException):
    """资源已存在"""
    status_code = 409
    default_detail = _('Have Existed.')
    default_code = 'have_existed'
```

### 自定义异常格式

**全局配置**

```python
## settings.py
REST_FRAMEWORK = {
    # 自定义异常格式
    'EXCEPTION_HANDLER': 'utils.custom_exception.custom_exception_handler',
}
```

**custom_response_exception.py**

```python
"""
自定义异常响应格式：{'code':0,'message':'成功','data':[]}
"""

from rest_framework.response import Response
from rest_framework.views import exception_handler


def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    res = {}
    if response is None:
        res = {
            'code': 9999,
            'message': '服务器未知错误'
        }
        return response
    else:
        data = []
        # print('exception', response.status_code, response.data)
        res['code'] = response.status_code
        if isinstance(response.data, dict):
            data = dict(response.data)

        if response.status_code >= 500:
            res['message'] = '服务器错误'

        elif response.status_code == 404:
            res['message'] = '未找到'

        elif response.status_code == 400:
            res['message'] = '参数错误'

        elif response.status_code == 401:
            res['message'] = '未认证'

        elif response.status_code == 403:
            res['message'] = '权限不允许'

        elif response.status_code == 405:
            res['message'] = '方法不允许'

        elif response.status_code == 409:
            res['message'] = '资源已存在'

        else:
            res['message'] = '未知错误'

        res['data'] = data
    	return Response(res)
```

### 自定义响应格式

**全局配置**

```python
# setting.py
REST_FRAMEWORK = {
    # 自定义响应格式
    'DEFAULT_RENDERER_CLASSES': [
        'utils.custom_response.CustomRenderer'
    ],
}
```

**custom_response.py**

```python
"""
自定义返回处理格式：{'code':0,'message':'成功','data':[]}
"""

from rest_framework.renderers import JSONRenderer


class CustomRenderer(JSONRenderer):
    # 重构render方法
    def render(self, data, accepted_media_type=None, renderer_context=None):
        print('renderer', data)
        ret = {}
        if renderer_context:
            # 如果返回的data为字典
            if isinstance(data, dict) and data.get('code') and data.get('message'):
                '''
                若响应信息中已有code、message，则pass返回
                '''
                ret = data
            elif isinstance(data, dict) and data.get('count') and data.get('results'):
                '''
                若响应信息中已有count、results，则为分页列表消息，对其格式化
                '''
                # ret['code'] = data.pop('code', renderer_context["response"].status_code)
                ret['code'] = 0
                ret['message'] = data.pop('message', '成功')
                ret['count'] = data['count']
                ret['next'] = data['next']
                ret['previous'] = data['previous']
                ret['data'] = data['results']
            else:
                '''
                若响应信息不是字典，则直接格式化返回
                '''
                # ret['code'] = renderer_context["response"].status_code
                ret['code'] = 0
                ret['message'] = '成功'
                ret['data'] = data

            renderer_context["response"]['status_code'] = 200
            return super().render(ret, accepted_media_type, renderer_context)
        else:
            return super().render(data, accepted_media_type, renderer_context)
```



### 自定义认证

#### Session

**全局配置**

```python
# setting.py
REST_FRAMEWORK = {
    # 自定义认证
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'utils.custom_authentication.CustomSessionAuth',
    ),
}
```

**局部使用**

```python
class BookView(APIView):
    authentication_classes = [CustomSessionAuth]
```

**保存session**

```python
request.session['id'] = 123
request.session['username'] = 'abc'
```

**验证**

```python
class CustomSessionAuth(BaseAuthentication):
    def authenticate(self, request):
        print('session', request.session)

        session_key = request.session.session_key
        if not session_key:
            raise AuthenticationFailed('未认证')
        if not request.session.get('id'):
            raise AuthenticationFailed('认证失败')

        return None
```



#### JWT Token

**全局配置**

```python
# setting.py
REST_FRAMEWORK = {
    # 自定义认证
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'utils.custom_authentication.CustomJWTAuth',
    ),
}
```

**局部使用**

```python
class BookView(APIView):
    authentication_classes = [CustomJWTAuth]
```

**生成 jwt token**

```python
import datetime
import jwt

def create_token(payload):
    print(type(payload))
    t = datetime.datetime.now()

    key = 'lp'

    payload['exp'] = datetime.datetime.utcnow() + datetime.timedelta(seconds=600)

    token = jwt.encode(payload=payload,
                       key=key,
                       algorithm='HS256')
    # print('create_token ', token)
    return token
```

**custom_authentication.py**

```python
import jwt
from jwt import exceptions
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

from apps.user.models import UserWechat

class CustomJWTAuth(BaseAuthentication):
    def authenticate(self, request):
        token = request.META.get('HTTP_Authorization'.upper())
        key = 'lp'
        payload = None
        if token is None:
            raise AuthenticationFailed('未认证')
        try:
            payload = jwt.decode(token, key, algorithms=['HS256'])
            # print('validate_token ', type(payload), payload)
        except exceptions.ExpiredSignatureError:
            raise AuthenticationFailed('签名已失效')
        except jwt.DecodeError:
            raise AuthenticationFailed('认证失败')
        except jwt.InvalidTokenError:
            raise AuthenticationFailed('签名非法')

        return None
```

### 自定义权限

**全局配置**

```python
'DEFAULT_PERMISSION_CLASSES': (
	'utils.custom_permission.CustomPermission',
),
```

**custom_permission.py**

```python
from rest_framework.permissions import BasePermission

class CustomPermission(BasePermission):
    message = '没有权限'

    def has_permission(self, request, view):
        print(request.user)
        print(view)
        if 1:
            return True
        else:
            return None
```

### 自定义限流

**全局配置**

```python
# 限流
'DEFAULT_THROTTLE_CLASSES': (
    'utils.custom_throttle.CustomAnonRateThrottle',  # 自定义游客
    'utils.custom_throttle.CustomUserRateThrottle',  # 自定义用户
),
'DEFAULT_THROTTLE_RATES': {
    'anon': '2/day',
    'user': '4/day'
},
```

**custom_throttle.py**

```python
from rest_framework.throttling import SimpleRateThrottle


class CustomAnonRateThrottle(SimpleRateThrottle):
    scope = 'anon'

    def get_cache_key(self, request, view):
        # print('限流Anon', str(request.user), type(request.user))
        if str(request.user) != 'AnonymousUser':  # 若不是匿名用户
            return None  # Only throttle unauthenticated requests.
        return self.cache_format % {
            'scope': self.scope,
            'ident': self.get_ident(request)
        }


class CustomUserRateThrottle(SimpleRateThrottle):
    scope = 'user'

    def get_cache_key(self, request, view):
        # print('限流User', request.user)
        if str(request.user) != 'AnonymousUser':  # 若不是匿名用户
            ident = request.user.id
        else:
            ident = self.get_ident(request)

        return self.cache_format % {
            'scope': self.scope,
            'ident': ident
        }
```



## DRF 状态码

```python
"""
Descriptive HTTP status codes, for code readability.

See RFC 2616 - https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
And RFC 6585 - https://tools.ietf.org/html/rfc6585
And RFC 4918 - https://tools.ietf.org/html/rfc4918
"""

def is_informational(code):
    return 100 <= code <= 199

def is_success(code):  # 成功
    return 200 <= code <= 299

def is_redirect(code):  # 重定向
    return 300 <= code <= 399

def is_client_error(code):  # 请求错误
    return 400 <= code <= 499

def is_server_error(code):  # 服务器错误
    return 500 <= code <= 599

HTTP_100_CONTINUE = 100  # 继续
HTTP_101_SWITCHING_PROTOCOLS = 101  # 切换协议
HTTP_200_OK = 200  # 正常
HTTP_201_CREATED = 201  # 已创建
HTTP_202_ACCEPTED = 202  # 已接受
HTTP_203_NON_AUTHORITATIVE_INFORMATION = 203  # 非授权信息
HTTP_204_NO_CONTENT = 204  # 无内容
HTTP_205_RESET_CONTENT = 205  # 重置内容
HTTP_206_PARTIAL_CONTENT = 206  # 部分内容
HTTP_207_MULTI_STATUS = 207  # 多状态
HTTP_208_ALREADY_REPORTED = 208  # 已报告
HTTP_226_IM_USED = 226  # 正在使用
HTTP_300_MULTIPLE_CHOICES = 300  # 多选择
HTTP_301_MOVED_PERMANENTLY = 301  # 永久重定向
HTTP_302_FOUND = 302  # 临时重定向
HTTP_303_SEE_OTHER = 303  # 分配新地址
HTTP_304_NOT_MODIFIED = 304  # 
HTTP_305_USE_PROXY = 305  # 
HTTP_306_RESERVED = 306  # 
HTTP_307_TEMPORARY_REDIRECT = 307  # 临时重定向2
HTTP_308_PERMANENT_REDIRECT = 308  # 
HTTP_400_BAD_REQUEST = 400  # 语法错误
HTTP_401_UNAUTHORIZED = 401  # 未认证
HTTP_402_PAYMENT_REQUIRED = 402  # 
HTTP_403_FORBIDDEN = 403  # 无权限
HTTP_404_NOT_FOUND = 404  # 未找到
HTTP_405_METHOD_NOT_ALLOWED = 405  # 方法不允许
HTTP_406_NOT_ACCEPTABLE = 406  # 
HTTP_407_PROXY_AUTHENTICATION_REQUIRED = 407  # 
HTTP_408_REQUEST_TIMEOUT = 408  # 
HTTP_409_CONFLICT = 409  # 
HTTP_410_GONE = 410  # 
HTTP_411_LENGTH_REQUIRED = 411  # 
HTTP_412_PRECONDITION_FAILED = 412  # 
HTTP_413_REQUEST_ENTITY_TOO_LARGE = 413  # 
HTTP_414_REQUEST_URI_TOO_LONG = 414  # 
HTTP_415_UNSUPPORTED_MEDIA_TYPE = 415  # 
HTTP_416_REQUESTED_RANGE_NOT_SATISFIABLE = 416  # 
HTTP_417_EXPECTATION_FAILED = 417  # 
HTTP_418_IM_A_TEAPOT = 418  # 
HTTP_422_UNPROCESSABLE_ENTITY = 422  # 
HTTP_423_LOCKED = 423  # 
HTTP_424_FAILED_DEPENDENCY = 424  # 
HTTP_426_UPGRADE_REQUIRED = 426  # 
HTTP_428_PRECONDITION_REQUIRED = 428  # 
HTTP_429_TOO_MANY_REQUESTS = 429  #   # 
HTTP_431_REQUEST_HEADER_FIELDS_TOO_LARGE = 431  # 
HTTP_451_UNAVAILABLE_FOR_LEGAL_REASONS = 451  # 
HTTP_500_INTERNAL_SERVER_ERROR = 500  # 服务器错误
HTTP_501_NOT_IMPLEMENTED = 501  # 
HTTP_502_BAD_GATEWAY = 502  # 
HTTP_503_SERVICE_UNAVAILABLE = 503  # 
HTTP_504_GATEWAY_TIMEOUT = 504  # 
HTTP_505_HTTP_VERSION_NOT_SUPPORTED = 505  # 
HTTP_506_VARIANT_ALSO_NEGOTIATES = 506  # 
HTTP_507_INSUFFICIENT_STORAGE = 507  # 
HTTP_508_LOOP_DETECTED = 508  # 
HTTP_509_BANDWIDTH_LIMIT_EXCEEDED = 509  # 
HTTP_510_NOT_EXTENDED = 510  # 
HTTP_511_NETWORK_AUTHENTICATION_REQUIRED = 511  # 
```

## Elasticsearch

- 需要安装 elasticsearch2.4.1并启动
- windows：https://www.cnblogs.com/hualess/p/11540477.html
- 中文分词：elasticsearch-ik

#### 安装

```sh
# 注意版本需相对应
pip install drf-haystack==1.8.10
pip install elasticsearch==2.4.1
```

#### 配置

```python
## settings.py

INSTALLED_APPS = 
[
	...
	'rest_framework'
	'haystack', 
]

# Haystack
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'haystack.backends.elasticsearch_backend.ElasticsearchSearchEngine',
        'URL': 'http://127.0.0.1:9200/',  # 此处为elasticsearch运行的服务器ip地址，端口号固定为9200
        'INDEX_NAME': 'fresh',  # 指定elasticsearch建立的索引库的名称
    },
}
# 当添加、修改、删除数据时，自动生成索引
HAYSTACK_SIGNAL_PROCESSOR = 'haystack.signals.RealtimeSignalProcessor'
# 指定搜索结果每页的条数
# HAYSTACK_SEARCH_RESULTS_PER_PAGE = 1
```

#### 创建索引类

```python
from django.db import models 
class Es(models.Model): 
    name=models.CharField(max_length=32)
    desc=models.CharField(max_length=32) 
```

#### 同目录app下创建search_indexes.py

```python
from haystack import indexes
from apps.product.models import ProductInfo


# 索引模型类的名称必须是 模型类名称 + Index
class ProductInfoIndex(indexes.SearchIndex, indexes.Indexable):
    # text表示被查询的字段，用户搜索的是这些字段的值，具体被索引的字段写在另一个文件里
    text = indexes.CharField(document=True, use_template=True)
    
    # 保存在索引库中的字段
    id = indexes.IntegerField(model_attr='id')
    name = indexes.CharField(model_attr='name')
    

    def get_model(self):
        return ProductInfo

    def index_queryset(self, using=None):
        return self.get_model().objects.all()

```

#### 创建模板文件

- 创建 templates/search/indexes/app/es_text.txt
- 名字要对应

```
{{ object.name }} 
{{ object.desc }}
```

#### 手动更新索引

- 数据库有多少条数据，全部会被同步到es中

```sh
# 首次重建
python manage.py rebuild_index
# 更新
python manage.py update_index
```

#### 创建haystack序列化器

```python
from drf_haystack.serializers 
import HaystackSerializer 
from rest_framework.serializers 
import ModelSerializer from app 
import models 
from app.search_indexes import EsIndex 
class EsSerializer(ModelSerializer): 
    class Meta: 
        model=models.Es 
        fields='__all__' 
class EsIndexSerializer(HaystackSerializer): 
     object = EsSerializer(read_only=True)  # 只读,不可以进行反序列化
     class Meta: 
        index_classes = [EsIndex]  # 索引类的名称
        fields = ('text', 'object')  # text：由索引类返回，固定名称；object：由序列化类返回
```

#### 类试图调用

```
from drf_haystack.viewsets 
import HaystackViewSet 
from app.models import Book 
from app.serializers import EsIndexSerializer 

class EsSearchView(HaystackViewSet): 
    index_models = [Es] 
    serializer_class = EsIndexSerializer
```

#### 路由

```python
from django.conf.urls 
import url from django.contrib 
import admin 
from rest_framework import routers 

from app.views import EsSearchView 
    router = routers.DefaultRouter() 
    router.register("book/search", EsSearchView, base_name="book-search") 
    urlpatterns = [ url(r'^admin/', admin.site.urls), ] 
    urlpatterns += router.urls
```

#### 测试

```
http://127.0.0.1:8000/?text=测试
```



## Celery

```
pip install django-celery
```

- proj/celery.py

```python
import os

from celery import Celery

from datetime import datetime, timedelta

# 设置默认的Django设置模块
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'alarmManagerBackend.settings')

app = Celery('alarmManagerBackend')

# 在这里使用字符串意味着worker不需要序列化
# 子进程的配置对象
# - namespace表示所有芹菜相关的配置键，应该有一个“CELERY_”前缀。
app.config_from_object('django.conf:settings', namespace='CELERY')

# 从所有注册的Django应用中加载任务模块。
app.autodiscover_tasks()

# 定时任务
app.conf.beat_schedule = {
    'skywalking_self_recover': {
        'task': 'skywalking.tasks.skywalking_self_recover',
        # 'schedule': timedelta(minutes=2)
        'schedule': 3
    },
}
```

apps/xxx/tasks.py

```python
from celery import shared_task

@shared_task
def task_demo():
    print(2)
    return 2
```

#### 启动命令

```sh
## windows
celery -A proj worker -l INFO --pool=solo -P eventlet
celery -A proj beat -l info

--logfile=E:\GCloud\alarmmanagerbackend\logs\celery.log
celery -A alarmManagerBackend beat -l info --

# linux启动，不要用root用户
celery multi start -A proj worker -l info --logfile=celery.log --pidfile=celery.pid
celery multi restart -A proj worker -l info --logfile=celery.log --pidfile=celery.pid
celery multi stop -A proj worker -l info --logfile=celery.log --pidfile=celery.pid

# celery进程全杀
ps auxww | grep 'celery' | awk '{print $2}' | xargs kill -9  
```



### 发邮件

#### 配置文件

```python
## settings.py

# 配置邮件服务器
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.163.com'  # 如果是 qq 改成 smtp.qq.com
EMAIL_PORT = 465  # 发邮件端口
EMAIL_HOST_USER = ''  # 邮箱
EMAIL_HOST_PASSWORD = ''  # 密码授权码
EMAIL_FROM = EMAIL_HOST_USER  # 发件人抬头
# EMAIL_USE_TLS = False  # 是否使用安全协议传输
EMAIL_USE_SSL = True
```

**安装celery**

```
pip install celery
```

项目下创建目录 celert_tasks

#### 创建celery异步任务

- celery_tasks/main.py

```python
import os

from celery import Celery

# 把celery和django进行组合，必须让celery能识别和加载django的配置文件以及django的类库
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "fresh.settings")

# 对django框架初始化
import django

django.setup()

# 创建Celery实例 生产者
app = Celery('fresh')

# 加载配置
app.config_from_object('celery_tasks.config')

# 注册任务，多任务写多个
app.autodiscover_tasks(['celery_tasks.email'])
```

celery_tasks/config.py

```python
# Celery配置文件
# 指定中间人、消息队列、任务队列、容器，使用redis
broker_url = 'redis://127.0.0.1/3'

# 结果队列的链接地址
celery_result_backend = 'redis://127.0.0.1:6379/14'
```

celery_tasks/email/tasks.py

```python
from celery import Task
from django.core.mail import send_mail
from django.conf import settings

from celery_tasks.main import celery_app


# 监听整个任务的钩子，有时任务会失败
class Mytask(Task):
    def on_success(self, retval, task_id, args, kwargs):
        print('task success！')
        return super(Mytask, self).on_success(retval, task_id, args, kwargs)

    def on_failure(self, exc, task_id, args, kwargs, einfo):
        print('task failed')
        # 可以记录到程序中或者任务队列中,让celery尝试重新执行
        return super(Mytask, self).on_failure(exc, task_id, args, kwargs, einfo)

    def after_return(self, status, retval, task_id, args, kwargs, einfo):
        print('this is after return')
        return super(Mytask, self).after_return(status, retval, task_id, args, kwargs, einfo)

    def on_retry(self, exc, task_id, args, kwargs, einfo):
        print('this is retry')
        return super(Mytask, self).on_retry(exc, task_id, args, kwargs, einfo)


@celery_app.task(name='send_verify_email', base=Mytask)  # name：起别名；base：为监听类
def send_verify_email(to_email, verify_url):
    """定义发送邮件的任务"""
    # send_mail('标题','普通邮件的正文','发件人','收件人列表','富文本邮件正文')
    project_name = 'test'
    subject = project_name + '邮箱验证'
    # message = '普通文本'
    # html_message是发送带html样式信息
    html_message = '<p>尊敬的用户您好！</p>' \
                   '<p>感谢您使用%s。</p>' \
                   '<p>您的邮箱为：%s 。请点击此链接激活您的邮箱：</p>' \
                   '<p><a href="%s">%s<a></p>' % (project_name, to_email, verify_url, verify_url)
    send_mail(subject, '', settings.EMAIL_FROM, [to_email], html_message=html_message)
```

#### 视图调用

```python
from celery_tasks.email.tasks import send_verify_email

class EmailView(APIView):
	def post(self, request):
        logger = logging.getLogger('django')
        send_verify_email.delay(email, verify_url)
        return JsonResponse({'code': 0, 'message': '成功'})
```

#### 启动

```sh
# windows测试启动
celery -A alarmManagerBackend worker -l INFO --pool=solo
celery -A alarmManagerBackend beat -l info

celery -A alarmManagerBackend worker -l INFO --pool=solo --logfile=E:\GCloud\API\alarmmanagerbackend\logs\celery.log
celery -A alarmManagerBackend beat -l info --logfile=E:\GCloud\API\alarmmanagerbackend\logs\celery.log

celery -A alarmManagerBackend worker --pool=solo -l info -P eventlet
celery -A alarmManagerBackend beat -l info -P eventlet


# linux启动，不要用root用户
celery multi start -A celery_tasks.main worker -l info --logfile=celery.log --pidfile=celery.pid
celery multi restart -A celery_tasks.main worker -l info --logfile=celery.log --pidfile=celery.pid
celery multi stop -A celery_tasks.main worker -l info --logfile=celery.log --pidfile=celery.pid

# celery进程全杀
ps auxww | grep 'celery' | awk '{print $2}' | xargs kill -9  
```



## 数据库读写分离

新建 db_router.py

```python
class MasterSlaveDBRouter(object):
    """数据库主从读写分离路由"""

    def db_for_read(self, model, **hints):
        """读数据库"""
        return "slave"

    def db_for_write(self, model, **hints):
        """写数据库"""
        return "default"

    def allow_relation(self, obj1, obj2, **hints):
        """是否运行关联操作"""
        return True　　
```

配置 setting.py

```python
DATABASE_ROUTERS = ["app.db_router.MasterSlaveDBRouter"]
```

## 生成接口文档

- 环境说明
  - python >= 3.6.2
  - Jinja2 <= 3.0.0

```sh
pip install coreapi
pip install djangorestframework 
```

**配置**

```python
## setting.py

INSTALLED_APPS = [
    ...
    'rest_framework'
]

REST_FRAMEWORK = {
    ...
	'DEFAULT_SCHEMA_CLASS': 'rest_framework.schemas.AutoSchema',
}
```

##### 路由

```python
urlpatterns = [
    path('docs/', include_docs_urls(title='接口文档')),
]
```

##### 访问

```
http://127.0.0.1:8000/docs
```



## 单元测试

#### 基本使用

```python
from django.test import TestCase

# 需要测试的函数
def add(a, b):
    return a + b

# 普通测试
d = add(1, 3)
assert d == 4  # 验证结果是否相等


class BookTestCase(TestCase):
    """框架测试"""
    
    @classmethod
    def setUpClass(cls):
        """所有测试用例之前调用"""
        pass
    
    @classmethod
    def tearDownClass(cls):
        """所有测试用例之后调用"""
        pass

    def setUp(self) -> None:
        """前置准备，每个测试方法之前调用"""
        pass

    def tearDown(self) -> None:
        """后置处理，每个测试方法之后调用"""
        pass

    def test_1(self): # 测试函数必须以 test 开头
        """测试功能"""
        c = add(1, 3)
        self.assertEqual(c, 1)  # 验证结果是否相等

    def test_2(self):
        c = add(-1, - 3)
        self.assertEqual(c, -4)
    
# python manage.py test
# python manage.py test 模块名
# python manage.py test 模块名.tests.类名
# python manage.py test 模块名.tests.类名.函数名
```

#### 模型测试

```python
class UserTestCase(TestCase):

    def setUp(self) -> None:
        # UserWechat.objects.create(openid='aaa')
        pass

    def test_user_create(self):
        """测试用户创建"""
        User.objects.create(username='aaa', gender='a')
        res = User.objects.get(username='aaa')
        self.assertEqual(res.username, 'aaa')

    def tearDown(self) -> None:
        pass
```

#### 接口测试

```python
class UserAPITestCase(TestCase):
    
    def test_hello(self):
        res = self.client.get('/hello')
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json().get('code'), 0)
        
    def test_login(self):
        data = {
            "openid": "acx",
            "nickname": "LP",
            "gender": 0
        }
        res = self.client.post('/login', data=data, content_type='application/json')
        self.assertEqual(res.status_code, 200)
```

##### Session

```python
import requests
from django.test import TestCase

class UserAPITestCase(TestCase):

    @classmethod
    def setUpClass(cls):
        """所有测试用例之前调用"""
        data = {
            "openid": "aaaa",
            "nickname": "LP",
            "gender": 0
        }
        cls.s = requests
        res = cls.s.post('http://127.0.0.1:8000/fresh/api/user/login', json=data)
        print('登录结果', res.json())
        pass

    @classmethod
    def tearDownClass(cls):
        """所有测试用例之后调用"""
        pass

    def test_logout(self):
        """需要session校验"""
        res = self.s.delete('http://127.0.0.1:8000/fresh/api/user/logout')
        self.assertEqual(res.status_code, 200)
```

## XAdmin

## Admin-simpleui

https://simpleui.72wo.com/docs/simpleui/

## Admin

### 修改admin标题

```python
from django.contrib import admin

admin.site.site_title = '管理后台'
admin.site.site_header = "xx管理后台"
```

### 导入导出

```sh
pip install django-import-export
```

```python
## settings.py
INSTALLED_APPS = [
	...
    'import_export',
    ...
]

## admin.py
from django.contrib import admin
from import_export import resources
from import_export.admin import ImportExportActionModelAdmin
from .models import Book

# 创建进出口资源
class BookResource(resources.ModelResource):
    class Meta:
        model = Book
        fields = ('id', 'name', 'price')  # 导出字段
        # exclude = ('imported', )  # 导出排除字段
        
@admin.register(Book)
class BookAdmin(ImportExportActionModelAdmin):
    resource_class = BookResource

    list_display = ('id', 'name', 'price', 'create_time')
```



## 项目部署

环境

```
nginx1.20.0
mysql5.7
redis5.0.3
django3.2.0
```

创建python虚拟环境

```sh
conda create -n fresh python==2.6.2

# 安装pip环境
pip install -r requirements.txt
# 安装uwsgi
pip install uwsgi
```

- pip mysqlclient报错

```
yum install mysql-devel
```

- pip uwsgi报错
- 参考：[乌斯吉 * Anaconda.org](https://anaconda.org/conda-forge/uwsgi)

```
conda install -c conda-forge/label/gcc7 uwsgi
```

#### 项目目录下创建 uwsgi.ini 文件

```ini
[uwsgi]
# 项目目录
chdir=/root/project/fresh
# 设置日志存储
daemonize=/root/project/fresh/uwsgi.log
# 你项目使用的虚拟环境的根目录 绝对地址
virtualenv = /root/miniconda3/envs/fresh
# 指定socket，真实端口
socket=:8001
# 指定pid文件
pidfile=/root/project/fresh/uwsgi.pid
# 指定项目的wsgi模块
module=fresh.wsgi
# 启用主进程
master=true
# 进程个数
workers=3
# 在每个worker而不是master中加载应用
lazy-apps=true
# 每个进程最大的请求数
max-request = 1000
# 启动uwsgi的用户名和用户组
uid=root
gid=root
# 自动移除unix Socket和pid文件当服务停止的时候
vacuum=true
# 启用线程
enable-threads=true
# 设置自中断时间
harakiri=30
# 设置缓冲
post-buffering=4096
#设置在平滑的重启（直到接收到的请求处理完才重启）一个工作子进程中，等待这个工作结束的最长秒数。这个配置会使在平滑地重启工作子进程中，如果工作进程结束时间超过了8秒就会被强行结束（忽略之前已经接收到的请求而直接结束）
reload-mercy = 8
```

#### 配置nginx

```sh
upstream fresh {
    server 127.0.0.1:8001;
}

server {
    listen 80;
    server_name www.smilelp.top;

    location = /ok {
        default_type application/json;
        return 200 '{"msg":"www.smilelp.top"}';
    }

    location / {
        include uwsgi_params;
        uwsgi_pass fresh;
        uwsgi_read_timeout 15;
    }

    location /static {
        alias /root/project/fresh/static;
    }

}
```

uwsgi启动 django项目

```sh
# 启动
uwsgi --ini uwsgi.ini
# 关闭
uwsgi --stop uwsgi.pid
# 重载nginx
systemcal reload nginx
```



### Docker部署

- docker+nginx+uwsgi+django+python+mysql+redis

https://blog.csdn.net/aafeiyang/article/details/100152373/

Dokerfile

```
FROM ubuntu:16.04
FROM python:3.6

ENV http_proxy=http://xxx.xxx.xxx.xxx:3128
ENV https_proxy=http://xxx.xxx.xxx.xxx:3128
 
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y \
    vim \
	git \
	python3-dev \
	python3-setuptools \
	python3-pip \
	nginx \
	supervisor \
        nodejs \
        npm \
        default-libmysqlclient-dev && \
        pip3 install --upgrade -i https://pypi.doubanio.com/simple/ pip setuptools && \
  	rm -rf /var/lib/apt/lists/*
 
RUN pip3 install -i https://pypi.doubanio.com/simple/ uwsgi
 
COPY requirements.txt /data/Project/
RUN pip3 install -i https://pypi.doubanio.com/simple/ -r /data/Project/requirements.txt
 
COPY ./build/nginx/nginx.conf /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY ./build/nginx/conf.d  /etc/nginx/conf.d
 
ENV PYTHONIOENCODING=utf-8
 
EXPOSE 9990 9999
```



**通过docker-compose.yml 将容器运行起来**

```yml
nginx:
    container_name: nginx
    image: registry.cn-shenzhen.aliyuncs.com/beni/nginx:latest
    ports:
        - 80:80
    volumes:
        - C:/data/django/nginx:/etc/nginx/conf.d
        - C:/data/django/www:/data/django/www
    links:
        - django:django
 
django:
    container_name: django
    image: registry.cn-shenzhen.aliyuncs.com/beni/django:latest
    volumes:
        - C:/data/django/www:/data/django/www
    command: uwsgi --ini /data/django/www/mblog/uwsgi.ini
```

