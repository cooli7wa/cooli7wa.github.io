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

{% for website in site.data.social %}
* {{ website.sitename }}：[@{{ website.name }}]({{ website.url }})
{% endfor %}

## Skill Keywords

{% for category in site.data.skills %}
### {{ category.name }}
<div class="btn-inline">
{% for keyword in category.keywords %}
<button class="btn btn-outline" type="button">{{ keyword }}</button>
{% endfor %}
</div>
{% endfor %}
