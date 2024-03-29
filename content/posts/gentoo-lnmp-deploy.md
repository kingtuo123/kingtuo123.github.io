---
title: "Gentoo 搭建 lnmp 环境"
date: "2021-06-08"
description: ""
categories: [ "linux" ]
tags: [ "gentoo" ]
---

## 安装配置 Mysql

```bash-session
# emerge -av dev-db/mysql
```

首次安装需配置root密码

```bash-session
# emerge --config dev-db/mysql
```

修改配置文件 `/etc/mysql/my.cnf`

```bash
[client]
socket=/var/run/mysqld/mysqld.sock
[mysqld]
#禁用远程访问，只使用本地socket连接
skip-networking 
#默认套接字路径
socket=/var/run/mysqld/mysqld.sock
#数据库默认存放路径
datadir=/var/lib/mysql/
```

启动 mysql

```bash-session
# rc-service mysql start
```

登陆 mysql

```bash-session
# mysql -u root -p
```

查看端口，port 为 0 表示远程连接关闭

```text
mysql>  show variables like 'port';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| port          | 0     |
+---------------+-------+
1 row in set (0.01 sec)
```


查看 socket 路径

```text
mysql>  show variables like 'socket';
+---------------+-----------------------------+
| Variable_name | Value                       |
+---------------+-----------------------------+
| socket        | /var/run/mysqld/mysqld.sock |
+---------------+-----------------------------+
1 row in set (0.01 sec)
```

查看数据库路径

```text
mysql>  show variables like 'datadir';
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| datadir       | /var/lib/mysql/ |
+---------------+-----------------+
1 row in set (0.00 sec)
```

## 安装配置 php

添加 USE 标记，编辑 `/etc/portage/package.use/package.use`，添加如下

```bash-session
# dev-lang/php fpm mysql mysqli gd
```
按需添加，查看各项USE标记含义，执行 `equery u dev-lang/php`
```
fpm     : Enable the FastCGI Process Manager SAPI
mysql   : Add mySQL Database support
mysqli  : Add support for the improved mySQL libraries
gd      : Adds support for gd (bundled with PHP)
```
安装 `dev-lang/php`，默认会安装最新的 php

```bash-session
# emerge -av dev-lang/php
```

查看版本，执行 `eselect php list cli` 或者执行 `php -v`

```bash-session
# eselect php list cli
[1]   php7.3 *
```

php 默认配置文件路径 `/etc/php/`，修改 `/etc/php/fpm-php7.3/fpm.d/www.conf` 文件

```text
user = nginx
group = nginx 
;默认是开9000端口用TCP连接，没有必要，注释掉改为本地socket连接
;listen = 127.0.0.1:9000 
listen = /var/run/php-fpm/php-fpm.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

编辑 `/etc/php/fpm-php7.3/php.ini`，修改下面内容

```text
;去掉下面这行注释并在末尾添加.html，支持解析html
security.limit_extensions = .php .php4 .php5 .php7 .html
cgi.fix_pathinfo=0
```

> 百度了下 cgi.fix_pathinfo，如果 PHP 的配置里 cgi.fix_pathinfo=1，会导致安全问题，这个问题只存在于 Nginx 服务器中，Apache 和 IIS 都不会有这个问题

## 安装配置 nginx

执行 `equery u nginx` 检查 USE 标记 `nginx_modules_http_fastcgi` 是否默认添加

```bash-session
# emerge -av www-servers/nginx
```

默认配置文件路径 `/etc/nginx/`，修改 `nginx.conf`

```nginx
server {
    listen       80 default_server;
    listen       [::]:80 default_server;
    server_name  localhost;

    include /etc/nginx/default.d/*.conf;
    	root  /home/test/www; #网站主目录

    location / {
    	root  /home/test/www;
    	index index.php index.html index.htm; 
    }

    location ~ .*\.(php|html)$ {  #添加php，html解析
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /home/test/www$fastcgi_script_name;
        include fastcgi_params;
    }
}

```

添加 nginx 到 test 用户组

```bash-session
# usermod -a -G  test nginx
```

查看用户组

```bash-session
# groups nginx
test nginx
```

最后，确保网站主目录的 group 有`r`和`x`权限。

## 测试

启动 nginx，执行`rc-service nginx start`，同样再启动 php-fpm 和 mysql

可以添加开机运行，执行`rc-update add <服务名称> default`

在网站主目录下新建 index.html，写入以下内容

```php
<?php
$con=mysqli_connect(null,"root","密码",null,null,"/var/run/mysqld/mysqld.sock");
if ($con){
    echo "连接成功";
}
?>

```

打开浏览器输入`127.0.0.1`，看到连接成功，配置成功

