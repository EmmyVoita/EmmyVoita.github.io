---
layout: custom-post
title:  "Improving Sampling Techniques for Cloud and Atmosphere Integration"
date:   2024-12-18 15:13:15 -0700
description: 
categories: jekyll update main
permalink:  
tags: Unity CloudAndAtmosphereRendering
---

Project Tasks:

When I first implemented the cloud sampling and atmosphere sampling in the same ray marching loop, I defined separate step sizes for sampling the atmosphere and for sampling the cloud calculated by dividing the distance inside their respective box by a sample count that I set as a variable. I tried to illustrate that in the figure below.  I then defined a maximum number of samples for the break condition.

![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_1.png){: .center }

Description: In the image above, the magenta box represents the atmosphere container, while the orange box represents the single cloud container. The bottom two rays correspond to the length of the dist inside each of the two containers above. I tried to illustrate how sampling would be distributed based on sample count N. 

This approach worked okay but, the atmosphere color inside of the container was clearly different from the surrounding environment. This was especially prevalent near the corners of the cloud container. I originally thought that this was due to some error with the density calculation not being multiplied by the step size, which is important for ensuring the scattered light scales correctly when there are different step sizes. But I determined that the issue was instead due to the atmosphere samples not being distributed the same when there is an offset from the cloud container. Below is an image that highlights that.

![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_2.png){: .center }

Description: In the image above, the magenta box represents the atmosphere container, while the orange box represents the single cloud container. The two gray rays represent two example view rays. The pink hashes represent the exit point from the cloud container. The cyan hashes mark the point where the raymarch exists due to hitting some max sample count. The cyan ray represents the distance copied from the left ray (pink to cyan hash).

The difference in the sampling position is important because the atmosphere scattering is dependent on the height of the current sample position. This issue could be resolved by increasing the sample count, but I figured that there would probably be a much better and cheaper way to approach the problem so I decided to go back and rework the whole sampling function. Here is an overview of how sampling is done now. This new sampling method also integrates dynamic step size for cloud density sampling, which is taken from my original cloud shader that I had prior to this project, and this is just an optimization that helps to avoid taking expensive samples where they are not necessary.

![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_3.png){: .center }

Here is the output of the combined shader with the new sampling model. I believe that in the image below I am taking 7 atmosphere samples and 32 cloud volume samples.

![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_4.png){: .center }

I also fixed the blue noise offset calculation, which helps to hide undersampling by offsetting the view ray. I didn't take a screenshot of that previously, so ignore the difference between the cloud lighting and shape.

Without Dithering 
![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_5.png){: .center }

With Dithering: 
![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_6.png){: .center }

I then tackled refining how the cloud coverage defined the main cloud shape. Previously, tiling of the cloud coverage texture was very noticeable. I had previously read about using a multiple channeled texture to represent cloud coverage probability from Nubis- Realtime Volumetric Cloudscapes In a Nutshell **[1](#Nubis)**, and I found several implementations of that method **[2](#HimalayasShaderToy)**, **[3](#SwissAlpsShaderToy)**, so I pretty much just copied that as I didn’t need to adapt it very much to work with my current implementation.

![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_7.png){: .center }
![Equations](/assets/images/Sprint 5/STG451Doccumentation_3_8.png){: .center }

Without Dithering: so this is the updated coverage, and you can refer to the previous image on page 27 tilted image A. 


<div class="reusable-divider">
    <span class="small-header-text">LINKS</span>
    <hr>
</div>

1. [Nubis: Authoring Real-Time Volumetric Cloudscapes](https://www.guerrilla-games.com/read/nubis-authoring-real-time-volumetric-cloudscapes-with-the-decima-engine){: #Nubis}
2. [Himalayas ShaderToy](https://www.shadertoy.com/view/MdGfzh){: #HimalayasShaderToy}
3. [Swiss Alps ShaderToy](https://www.shadertoy.com/view/ttcSD8){: #SwissAlpsShaderToy}




[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
