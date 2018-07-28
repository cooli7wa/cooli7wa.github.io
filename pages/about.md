---
layout: page
title: About
description: 目标和坚持，会改变一切
keywords: Cooli7wa
comments: False
menu: 关于
permalink: /about/
---

眼光放得长远一些，看到的东西也会多一些，生活也就会过得更有意义一点

## 联系

{% for info in site.data.social %}
{if {{info.type}} == "website"}
* {{ info.sitename }}：[@{{ info.name }}]({{ info.url }})
{else {{ info.type }} == "email"}
* 邮箱：{{ info.address }}
{else {{ info.type }} == "other"}
* {{ info.name }}：{{ info.number }}
{/if}
{% endfor %}

## 编程语言

<div class="btn-inline">
{% for skill in site.data.skills %}
<button class="btn btn-outline" type="button">{{ skill }}</button>
{% endfor %}
</div>

## 兴趣方向

<div class="btn-inline">
{% for direction in site.data.learning_direction %}
<button class="btn btn-outline" type="button">{{ direction }}</button>
{% endfor %}
</div>

## 完成课程

{% for zs in site.data.zhengshu %}
* {{ zs.pingtai }}: {{ zs.name }}
{% endfor %}
