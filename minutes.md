---
layout: page
title: Actas
permalink: /actas/
---

<ul>
{% assign items = site.minutes | sort: 'fecha' | reverse %}
{% for minute in items %}
  <li>
    <a href="{{ minute.url }}">
      Sesión {{ minute.type | capitalize }} {{ minute.number }}-{{ minute.date | date: "%Y" }}
    </a>
    {% if minute.file %}
      — <a href="{{ minute.file }}" target="_blank" rel="noopener">PDF</a>
    {% endif %}
  </li>
{% endfor %}
</ul>

