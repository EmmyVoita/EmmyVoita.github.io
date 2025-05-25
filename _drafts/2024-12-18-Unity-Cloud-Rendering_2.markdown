---
layout: custom-post
title:  "Refactoring and Enhancing Cloud Shader Integration"
date:   2024-12-18 15:13:15 -0700
description: 
categories: jekyll update main
permalink:  
tags: Unity CloudAndAtmosphereRendering
---

To combine my cloud shader with the atmosphere shader, I felt that it was important to go back and refine my current code and comments. This gives me the time to refamiliarize myself with how the shader works, as I haven't really looked at it in a few months. During this revision, I opted to abstract all relevant variables into distinct compute includes, relocating shader parameters from the primary script that invokes the shader to separate scriptable objects. This process also involved the addition of comprehensive tooltips for each variable, as well as the resolution of prior issues related to lighting and cloud shape construction. In the process I added a bit more functionality such as support for multiple frame rendering modes, dictating the number of frames required for complete image generation. Below are some images showcasing that:

Description: On the left is before, and on the right is after.

![Image1](/assets/images/Sprint 3-4/STG451Doccumentation_2_1.png){: .center }

Description: Here is an example of one of the scriptable objects

![Image2](/assets/images/Sprint 3-4/STG451Doccumentation_2_2.png){: .center }

Description: Here is a before and after with the updated lighting and shape settings. Ignore the yellow line. 

![Image3](/assets/images/Sprint 3-4/STG451Doccumentation_2_3.png){: .center }

There were a couple modifications that I made to make the shader compatible with the atmosphere rendering model that I have been working on previously. The first was modifying the cloud color calculation to be dependent on scattering coefficients, like the atmosphere, rather than blend between a top and bottom color.  Presented below  is a demonstration of colored scattering. It's worth noting that the current scattering coefficients do not precisely mirror those of Earth, hence the resulting coloration.

![Image4](/assets/images/Sprint 3-4/STG451Doccumentation_2_4.png){: .center }

And this might be a property that I would allow to be set independent of the atmosphere scattering coefficients, as it could allow for more artistic control over cloud color. For example, here I have purple light scattering. 

![Image5](/assets/images/Sprint 3-4/STG451Doccumentation_2_5.png){: .center }

The second modification was the removal of the following optimization technique. I’m unsure whether marching at variable step sizes will affect the atmosphere luminance accumulation. In theory it shouldn’t as long as the step size is taken into account, but it is better to remove it for now to avoid potential issues.  Consequently, the shader now employs two distinct loops: one for the primary ray and another for the light ray, which aligns with the atmosphere shader.

![Image6](/assets/images/Sprint 3-4/STG451Doccumentation_2_6.png){: .center }

High Level Overview of Integrated Single Cloud Volume and Atmosphere Marching:

![Image7](/assets/images/Sprint 3-4/STG451Doccumentation_2_7.png){: .center }

Description: In the image above, the magenta box represents the atmosphere container, while the yellow box represents the single cloud container. There are also hashes along the view ray representing samples. Yellow represents a cloud and atmosphere sample, while red represents just an atmosphere sample.
Note: If the ray intersects a cloud container, then it is guaranteed to be within the bounds of the atmosphere. Thus, there is no need to do an additional check for the atmosphere intersection. This is shown in the flowchart. 



While a single cloud volume in the scene has a relatively straightforward integration, supporting multiple cloud volumes introduces some problems better addressed after successfully implementing a single volume.

One streamlined approach for accommodating multiple cloud volumes involves combining cloud containers into a unified baked 3D texture, which is a tool I would need to create. This would speedup checks for ray-volume intersections, although at the expense of increased overhead for managing and accessing a 3D texture. It might be worthwhile to experiment with lower resolution textures . Given that cloud containers are defined by rectangular prisms, a reduction in texture resolution may not dramatically impact the output. However, this introduces the challenge of managing distinct settings for various cloud volumes, since it's not possible to encapsulate all necessary information within the 3D texture.  A potential workaround I can think of is utilizing the value in the cloud container 3D texture as an index for an array of cloud settings. This approach is likely to be more efficient than alternative methods (such as checking through a list of ray box intersections),  especially with a larger number of containers, though it would require thorough testing.


I also spent a considerable amount of time trying to understand and integrate a deep shadow map generator into my cloud marching. A deep shadow map extends the concept of a standard shadow map by storing a function of attenuation over depth. This enables the deep shadow map to handle scenarios where multiple occluders are present at different distances along a ray from the light source, which is particularly important for scenes with semi-transparent or translucent surfaces, like volumetric rendering (shown below), where standard shadow maps would fail to accurately represent the occlusion. I found an implementation in Unity **[1](#UnityDeepShadowMap)** that is based off of the source code in the book GPU Pro 4 **[2](#GPUProSourceCode)**. That implementation creates a deep shadow map for hair, so I have been trying to adapt it for my use case. 

![Image8](/assets/images/Sprint 3-4/STG451Doccumentation_2_8.png){: .center }

The conventional method for generating a deep shadow map involves ray marching along the light ray and recording attenuation at each step within a 3D texture **[3](#DeepShadowMaps)**.  In my case, I'm already marching the light ray while marching through the cloud/atmosphere volume, so I have been working on updating my deep shadow map texture simultaneously. While I believe this approach is likely the most efficient, I do anticipate potential temporal issues, especially if I'm rendering the full frame over multiple frames. Given the time I've already invested in trying to get shadows to work, I'm thinking I will approach this after I implement temporal reprojection. This way, I'll be in a better position to address any issues that may arise.

<div class="reusable-divider">
    <span class="small-header-text">LINKS</span>
    <hr>
</div>


1. [Unity Deep Shadow Map](https://github.com/ecidevilin/DeepShadowMap/tree/master){: #UnityDeepShadowMap}
2. [GPU Pro Source Code](https://github.com/ecidevilin/GPU-Pro-Books-Source-Code){: #GPUProSourceCode}
3. [Deep Shadow Maps Research Paper](https://graphics.stanford.edu/papers/deepshadows/deepshad.pdf){: #DeepShadowMaps}


[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
