---
layout: static
title: All Articles - Thomas Maximini
headline: Articles
permalink: /articles/
---
<ul class="article-list">
  {% for post in site.posts %}
    <li>
      <span class="post-date">{{ post.date | date: "%b %-d, %Y" }}</span><br>
      <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

<p class="rss-subscribe">subscribe <a href="{{ "/feed.xml" | prepend: site.baseurl }}">via RSS</a></p>