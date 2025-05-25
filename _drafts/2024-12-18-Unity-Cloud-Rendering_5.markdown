---
layout: custom-post
title: "Attempting Optimizing Volumetric Rendering with Temporal Techniques"
date: 2024-12-18 15:13:15 -0700
image: /assets/Images/Sprint 5/cloudsimage_01.PNG
description: 
categories: jekyll update main
permalink:  

tags: Unity CloudAndAtmosphereRendering
permalink:  /posts/Attempting-Optimizing-Volumetric-Rendering-with-Temporal-Techniques/
---



<div class="reusable-divider">
    <span class="small-header-text">Overview</span>
    <hr>
</div>

After refining cloud shape and lighting, I wanted to reattempt implementing some optimizations, and temporal reprojection and anti-aliasing techniques. The main optimization commonly used in volumetric rendering involves rendering a single frame over multiple frames. 

As an important note, while some of the theory discussed in this post is correct, the implemention of temporal reprojection and anti-aliasing is wrong. If you want to see my sucessful implementation, see [this](/posts/Fixing-Real-Time-Optimizations-For-Volumetric-Rendering/) post.

<div class="reusable-divider">
    <span class="small-header-text">Rendering Over Multiple Frames:</span>
    <hr>
</div>


The simplest way to split up rendering a single frame over multiple frames would be to divide the output texture into blocks of nxn size, where n is commonly 4, and each frame move along and update one texel per block in the render texture. 

For example, on the first frame each texel with id 1 in the 4x4 block would get updated. Then in the second frame, each texel with id 2 in the 4x4 block would be updated, and so on and so forth.  

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_1.png){: .center .add-small-spacing .image-with-shadow}

But this update method produces a noticeable cyclic pattern over time. The better alternative, which is used in **[1](#SwissAlpsShaderToy)** and mentioned in **[2](#JPG)**, although for a different purpose, is to use a 4x4 bayer matrix that, while deterministic, creates a pattern that appears random. Here is an example of what the update order for that looks like. 

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_2.png){: .center .add-small-spacing .image-with-shadow}

**Reprojection of Static Scenes:**
 	
As outlined in the The GDC presentation “Temporal Reprojection Anti-Aliasing in INSIDE” **[3](#INSIDE)**, if a scene is static (meaning it doesn't change over time), generally the current fragment can be reprojected into the past frame using the previous frames view-projection matrix and the world position for the current frame. This reprojected uv can then be used to sample the history buffer, which can be blended with the current fragment to provide a more accurate representation of the scene. This is especially important when a scene is only partially updated per frame, as is often the case with expensive raymarch because of how much of a performance gain there can be.

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_3.png){: .center .add-small-spacing .image-with-shadow}

In my case I am storing the depth data in the alpha channel of the atmosphere raymarch color. So I have modified my pipeline so that rather than rendering that directly to the scene, I pass the output of the atmosphere shader into a post processing compute shader which handles the temporal reprojection and temporal anti-aliasing using that depth channel.  I included a basic flow chart of that below.

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_4.png){: .center .add-small-spacing .image-with-shadow}

Right now I don’t see much of an improvement between sampling the history buffer using the reprojected uv vs the same uv as the current frame, and that could be due to several reasons. For one, the reprojection relies on the world position buffer being up to date which isn’t necessarily the case if im passing the world position data in the same partial frame update method. I'm not sure how much this affects the end results, but the solution could potentially involve blending with surrounding texels, potentially giving weight to values updated in the current frame to account for temporal coherence.

Additionally, this reprojection method has some errors when objects in the scene are dynamic. To handle reprojection for dynamic objects there needs to be a velocity buffer, which I have not implemented yet, and plan on doing next semester. Right now a basic form of anti-aliasing is accomplished by performing neighborhood clamping on the color space, which is then blended with the history buffer sample. It isn’t the exact same sampling distribution method as below, but I believe that the image highlights the main points.

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_5.png){: .center .add-small-spacing .image-with-shadow}
![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_6.png){: .center .add-small-spacing .image-with-shadow}

And then here is how reprojection of dynamic scenes could be approached using a velocity buffer. I had previously attempted to implement this prior to this class, but I wasn’t able to get very good results for many reasons.I believe the main reason was that I was approaching updating texels in a suboptimal way that made everything else very difficult due to a lack of valid data.

Here is what the motion vector buffer would look like, on the left. It is a 2 channel texture with x and y representing the direction that some object has moved between the previous frame and the current frame.

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_7.png){: .center .add-small-spacing .image-with-shadow}
![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_8.png){: .center .add-small-spacing .image-with-shadow}

<div class="reusable-divider">
    <span class="small-header-text">Lighting Changes</span>
    <hr>
</div>

Finally I made a couple more changes to how the lighting works to allow beer-powder effect to be more prevalent without causing these overly dark spots because the color information is being lost due to the power function that I use, which I think looks better. 


![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_9.png){: .center .add-spacing-with-description .image-with-shadow} 

<div class="custom-image-description">
Old Method
</div>


![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_10.png){: .center .add-spacing-with-description .image-with-shadow} 

<div class="custom-image-description">
New Method
</div>

To accomplish this, rather than directly using the beer-powder [1 - exp(-density)] expression, I lerp between two clamped versions of that expression using the original expression, which helps to prevent the output color from becoming too dark. The “BEER_POWDER_SCALAR” is just a scalar to give some control over the brightness of the output color.

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_11.png){: .center .add-spacing-with-description .image-with-shadow}

Here is a showcase of the sunrise and sunset with 64 cloud samples. You can also really notice the ghosting when the camera is in motion here:  

![2025-01-3015-55-43-ezgif com-optimize](/assets/videos/Clouds/2025-01-3015-55-43-ezgif.com-optimize.gif){: .center .add-spacing-with-description .image-with-shadow} 


This is really the most amount of samples that you would set for the cloud volume, as anything higher is hard to notice unless the beer-powder effect is fully visible, and even then, there is probably a way to blend the result of undersampling with noise to make it less noticeable. Here is that case where the beer-powder effect is fully visible. You can notice that the shadows are more blended with the higher sample count compared to the lower sample count:

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_12.png){: .center .add-spacing-with-description .image-with-shadow}

<div class="custom-image-description">
Description: Here is an image of the scene to give more context for the images below. The directional light is positioned behind the viewer at 10 degrees above the horizon, which makes the beer-powder effect very visible.
</div>

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_13.png){: .center .add-spacing-with-description .image-with-shadow}



<div class="reusable-divider">
    <span class="small-header-text">Next Steps:</span>
    <hr>
</div>


As mentioned before, the current implementation for temporal reprojection and anti-aliasing is very basic, and there is a lot of room for improvement. 

And then here is just a couple different viewer perspectives:

![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_14.png){: .center .add-small-spacing .image-with-shadow}
![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_15.png){: .center .add-small-spacing .image-with-shadow}
![Equations](/assets/images/Sprint 6/STG451Doccumentation_4_16.png){: .center .add-small-spacing .image-with-shadow}

<div class="reusable-divider">
    <span class="small-header-text">LINKS</span>
    <hr>
</div>

1. [Swiss Alps ShaderToy](https://www.shadertoy.com/view/ttcSD8){: #SwissAlpsShaderToy}
2. [JPG's Volumetric Clouds](https://www.jpgrenier.org/clouds.html){: #JPG}
3. [Temporal Reprojection Anti-Aliasing in INSIDE](https://s3.amazonaws.com/arena-attachments/655504/c5c71c5507f0f8bf344252958254fb7d.pdf?1468341463){: #INSIDE}


[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
