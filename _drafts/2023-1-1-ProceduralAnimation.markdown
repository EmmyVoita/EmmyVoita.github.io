---
layout: custom-post
title: "Procedural Animation"
date: 2025-1-18 15:13:15 -0700

categories: jekyll update main

tags: Unity 
image: 
description:
permalink:  /posts/Procedural-Animation/
---

* [Overview](#overview)
* [Challenges](#challenges)
* [Resources](#links)


<div class="reusable-divider">
    <span class="small-header-text" id="overview">Overview</span>
    <hr>
</div>

In trying to start the task of remaking our first level’s enemies I decided to try to implement custom procedural animation. In doing that I learned about using callbacks from refactoring my algorithm for determining when each leg should take a step to utilize a queue and callbacks

<div class="reusable-divider">
    <span class="small-header-text" id="overview">Project Tasks</span>
    <hr>
</div>

Procedural animation base for a quadruped character using a modified version of EasyIK (2), which is just a free basic implementation for inverse kinematics.

There are better solutions for applying inverse kinematics to an animated/rigged character, but I wanted to have more control over the animation, and I liked the flexibility that was described in the following video through using second order dynamics, so I decided to implement that. 

My first implementation looked like this:

![2025-01-2416-33-06-ezgif.com-optimize](/assets/videos/Unity3DGame/2025-01-2416-33-06-ezgif.com-optimize.gif){: .center .add-spacing } 



What I have at the moment is very rudimentary, as I was refactoring the algorithm that I was using to control the individual leg motion. I went from trying to use some pattern to define when legs should and shouldn't move to using a queue and callbacks.

<div class="padded-code-block">
{% highlight C# %}

{% endhighlight %}
</div>

<div class="reusable-divider">
    <span class="small-header-text" id="links">LINKS</span>
    <hr>
</div>

1. [Giving Personality to Procedural Animations using Math](https://www.youtube.com/watch?v=KPoeNZZ6H4s)

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
