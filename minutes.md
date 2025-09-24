---
layout: page
title: Actas
permalink: /actas/
---

{% assign items = site.minutes | sort: 'date' | reverse %}
{% assign years = items | group_by_exp: 'i', "i.date | date: '%Y'" %}

{::nomarkdown}
{% for y in years %}
  <h2>{{ y.name }}</h2>
  {% assign grouped = y.items | group_by_exp: 'i', "i.date | date: '%m'" %}
  {%- assign grouped = grouped | sort: 'name' | reverse -%}

  {% for m in grouped %}
    {% assign mes_index = m.name | plus: 0 | minus: 1 %}
    {% assign mes_nombre = site.locales.es.months[mes_index] %}

    <h3>{{ mes_nombre | capitalize }}</h3>
    <ul>
      {%- assign month_items = m.items | sort: 'date' | reverse -%}
      {% for minute in month_items %}
        <li>
          <a href="{{ minute.url | relative_url }}">{{ minute.title }}</a>
          {% if minute.file %}
            - <a href="{{ minute.file | relative_url }}" target="_blank" rel="noopener">PDF</a>
          {% endif %}
        </li>
      {% endfor %}
    </ul>
  {% endfor %}
{% endfor %}
{:/nomarkdown}
