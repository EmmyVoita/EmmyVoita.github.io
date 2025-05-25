---
layout: custom-post
title:  "1st Iteration of Atmosphere Model"
date:   2024-12-18 15:13:15 -0700
description: 
categories: jekyll update main
permalink:  
tags: Unity CloudAndAtmosphereRendering
---


The first iteration of my AtmosphereCompute.compute shader was built using a combination of the approaches outlined by Dimas Leenman **[1](#AtmosphereShaderToy)** and Simon Dev **[2](#simondev)**. Following research into more complex approaches, I felt that it would be most beneficial to try and follow the model outlined by Sébastien Hillaire **[3](#sebastien)**. For the first week of sprint 2, I worked on modifying the shader to try and follow the model outlined by Sébastien Hillaire **[3](#sebastien)**. As outlined in the paper, under strong real-time constraints, their approach relies on ray marching to first evaluate single scattering. The following 4 equations outline that approach:

![Equations](/assets/images/Sprint 2/STG451Doccumentation_1.png){: .center }

<div class=".container">
    <span class="small-header-text" style="display: block; margin: 0; padding: 0;">EQUATIONS FOR PARTICIPATING MEDIA RENDERING</span>
    <hr style="border: 1px dotted #333; margin-top: 0px; margin-bottom: 20px;">
</div>

I’ve included hand drawn images that go over each of the equations, what the variables represent, and my thought process with things. My current implementation doesn’t fit this model exactly, but it’s close enough to where I think I can continue to build on it further following their approach without running into issues. Most notably, instead of having a separate function to calculate transmittance, I calculate the optical depth and use attenuation to calculate my in-scatter sum. 

My implementation of Sébastien Hillaire’s model can be broken down into the following pseudocode:

{% highlight text %}
Ray marching primary ray:
- Accumulate optical depth
- Using current optical depth, calculate attenuation
- For each light, ray marching light ray:
    - Calculate total optical depth (light)
    - Using total optical depth (light), calculate attenuation
    - Calculate ShadowFactor
    - Calculate Ei
    - Calculate phase p(v,li)
    - In-Scatter Sum += density * attenuation * ShadowFactor *  phase * illuminance 
- March along primary ray

Final Luminance = extinction coefficient * In-Scatter Sum * Ambient + scene * opacity
{% endhighlight %}


![Equation 1](/assets/images/Sprint 2/STG451Doccumentation_2.png){: .center.rotate-270 }

![Equation 2](/assets/images/Sprint 2/STG451Doccumentation_3.png){: .center }

![Equation 3](/assets/images/Sprint 2/STG451Doccumentation_4.png){: .center }

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_5.png){: .center }

<div class=".container">
    <span class="small-header-text" style="display: block; margin: 0; padding: 0;">SHADOW MAPPING</span>
    <hr style="border: 1px dotted #333; margin-top: 0px; margin-bottom: 20px;">
</div>

I was able to successfully implement the model with exception to the shadow factor S(x,li). The issue with implementation stems from the function denoted by Vis(li), which should return 1 if the light ray travels from the current sample point to the atmosphere edge without intersecting the ground, or 0 if the light ray intersects the ground, as illustrated in the figure below.

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_6.png){: .center }

As explained in the Shadow Mapping article on LearnOpenGL **[4](#LearnOpenGL)**, the idea behind shadow mapping is that if we view the scene from the light's perspective, everything we see is lit and everything we can't see must be in shadow. To implement this, first render the scene from the light’s perspective and store the depth information in a texture known as a shadow map. When we want to determine if a position is in shadow, we transform it into the light’s coordinate system using the light’s view-projection matrix (Let that transformed position be ProjCoord). Next, we sample the shadow map using ProjCoord.xy, and compare the depth value from the shadow map against ProjCoord.z. If the depth in the shadow map is less than ProjCoord.z, then that point is in shadow.

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_7.png){: .center }

Implementing the shadow map and depth comparison in Unity 2021.3.9f1’s Built-in Render Pipeline wasn’t too difficult. The main issue I had was struggling to find documentation. In the end, I ended up closely following Shahriar Shahrabi’s tutorial **[5](#CustomShadowMapping)** on custom shadow mapping. Here is a basic outline of what that looks like:

Step 1:  Grab the depth information from the directional light and render it to a global texture. 

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_8.png){: .center }

Step 2:  Convert the world space position to the light’s coordinate space using unity_WorldToShadow[]. Then, sample the MainShadowmapCopy texture using the shadowCoord, and finally compare the depth values. 

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_9.png){: .center }

This implementation produces the expected results when just passing the world position buffer as the current_sample_pos, as shown in figure 1 below. And In theory, it should work independent of what value is passed for the current_sample_pos.  To implement this into the AtmosphereShader.compute script, I compute the shadow factor for each step along the primary ray, and multiply the attenuation by the max between some minimum value (representing ambient light) and one minus the shadow factor. This statement essentially says the following:

If primary_sample_pos is in shadow, multiply the attenuation by 0 or some min value. Therefore, no or little light will be in-scattered.
If primary_sample_pos is not shadow, multiply the attenuation by 1. Therefore, some light will be in-scattered.

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_10.png){: .center }

Also note accumulated_shadow_factor is used to compute an average_shadow_factor after raymarching to affect the opacity of the scene_color. Without this adjustment, the scene does not get correctly lit, as illustrated in figure 2 below.

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_11.png){: .center }

*__Figure 1:__ The image on the left shows the shadow factor (white -> in shadow), middle the world position buffer, and right the scene color.* 

![Equation 4](/assets/images/Sprint 2/STG451Doccumentation_12.png){: .center }

*__Figure 2:__ Both images return that the entire scene is in shadow (for demonstration). The image on the left uses the average_shadow_factor to affect the opacity, while the image on the right does not.*


While in theory the ShadowFactor function should work independent of what value is passed for the current_sample_pos, meaning it should work for any position primary_sample_pos might be, currently the depth value comparison is showing that the two depth values are equal. I have gone through trying to figure out the cause of this issue, and I believe that it is due to a precision issue since I am working with values that are scaled to represent the Earth’s properties. To determine whether this is the issue,  I have been trying to implement a compute buffer. However, that has proven a lot more challenging than I initially thought because  the amount of data I write to the compute buffer varies significantly between frames, so it’s quite hard to manage how many bytes of data I am expecting to output. 

<div class="reusable-divider">
    <span class="small-header-text">LINKS</span>
    <hr>
</div>




1. [Atmosphere Rendering ShaderToy](https://www.shadertoy.com/view/wlBXWK){: #AtmosphereShaderToy }
2. [SimonDev Atmosphere Rendering](https://github.com/simondevyoutube/ProceduralTerrain_Part10/blob/main/src/scattering-shader.js){: #simondev }
3. [Sébastien Hillaire's Production Ready Sky and Atmosphere Rendering](https://sebh.github.io/publications/egsr2020.pdf){: #sebastien }
4. [Learn OpenGL Shadow Mapping](https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping){: #LearnOpenGL }
5. [Custom Shadow Mapping in Unity](https://shahriyarshahrabi.medium.com/custom-shadow-mapping-in-unity-c42a81e1bbf8){: #CustomShadowMapping }

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
