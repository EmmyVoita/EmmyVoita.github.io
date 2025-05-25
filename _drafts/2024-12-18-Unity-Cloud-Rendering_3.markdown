---
layout: custom-post
title:  "Adding Debug Tools for Cloud and Atmosphere Integration"
date:   2024-12-18 15:13:15 -0700
description: 
categories: jekyll update main
permalink:  
tags: Unity CloudAndAtmosphereRendering
---

Project Tasks: 

In preparation for combining my atmosphere and cloud shader, I have added several debugging features that should both help the user to identify and understand how different properties influence output and help with pinpointing issues that arise, if any do occur, as a result of doing the cloud and atmosphere calculations during the same ray march.

Texture Debugger Example:
For cloud coverage, I have introduced debugger settings that help to visualize the top and bottom rounding of clouds

![Equations](/assets/images/Sprint 3-4/STG451Doccumentation_2_9.png){: .center }

Here is a clear example of how the texture viewer can help to understand how different properties impact the result. Cloud coverage is determined in part by a double remap to round the top and bottom of clouds, which can be difficult to visualize when there are numerous input variables.

![Equations](/assets/images/Sprint 3-4/STG451Doccumentation_2_10.png){: .center }

So I  have introduced channels for different steps in the computation process to help show exactly what is going on. This is done by modifying the output texel in the same compute shader if the viewer is enabled and the thread id lies within the defined bounds of the viewer box. 

![Equations](/assets/images/Sprint 3-4/STG451Doccumentation_2_11.png){: .center }

I also copied a few of the functions used in the compute shader into a C# script and added multiple on draw gizmo utilities to help with visualizing what is actually happening in the compute shader. I ran into some issues that revolved around the ray/box intersection test and planet data struct creation, and I figured that this would probably be the best way to approach the problem. I talk about the use cases for each of these visualizations in the included loom videos. 

![Equations](/assets/images/Sprint 3-4/STG451Doccumentation_2_12.png){: .center }
![Equations](/assets/images/Sprint 3-4/STG451Doccumentation_2_13.png){: .center }
![Equations](/assets/images/Sprint 3-4/STG451Doccumentation_2_14.png){: .center }



[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
