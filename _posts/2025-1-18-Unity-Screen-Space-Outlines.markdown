---
layout: custom-post
title: Screen Space<br>Outlines
date: 2025-01-18 00:00:00 -0700
permalink: /posts/Unity-URP-Screen-Space-Outlines/
image: /assets/Images/ScreenSpaceOutlines/cropped-Outlines Card Image.PNG
description: >
  Building on a Unity screen space outline effect by improving edge detection
  and implementing Temporal Anti-Aliasing.
categories: jekyll update main
tags: [Unity, URP, RenderGraph]
priority: 3
---


<!--
This project is an enhancement of Robin Seibold's screen space outlines implementation, which I expanded upon to meet the requirements of various projects I was working on. These enhancements included improving edge detection and adding anti-aliasing. I initially worked on this project using Unity version 2022.3.50f1, but I encountered issues with setting multiple render targets, which I needed for implementing a Temporal Anti-Aliasing (TAA) shader. To diagnose bugs, I relied heavily on RenderDoc and eventually decided to switch to Unity 6.0 to use the Render Graph system.
-->

![2025-01-1915-50-26-ezgif com-optimize](/assets/videos/ScreenSpaceOutlines/2025-01-1915-49-35-ezgif.com-optimize.gif){: .post-header-image-with-description .clickable-image} 
* [Overview](#overview)
* [Temporal Anti-Aliasing](#temporal-anti-aliasing)
    * [Ensuring TAA Compatibility with the Outline Shader](#Ensuring-TAA-Compatibility)
* [Non Maximum Suppression](#non-maximum-suppression)
* [Future Work](#future-work)
* [Resources](#links)


<div class="reusable-divider">
    <span class="small-header-text" id="overview">Overview</span>
    <hr>
</div>

Outlines are a commonly used visual effect across many genres of games. They serve various purposes, from enhancing object readability and emphasizing interactable elements to contributing to stylized rendering such as cel shading. There are numerous ways to implement outlines, each with trade-offs in performance,  flexibility, and visual quality. 

This project builds upon Robin Seibold's screen space outlines implementation **[3](#RSVideo)** **[4](#RSGithub)**, improving edge detection and incorporating anti-aliasing. Initially, I developed the project using Unity 2022.3.50f1 but encountered limitations with setting multiple render targets, which were essential for implementing a Temporal Anti-Aliasing (TAA) shader. To address these challenges and to learn features in the latest Unity versions, I transitioned to Unity 6.0 to use the Render Graph system.

<div class="reusable-divider">
    <span class="small-header-text" id="temporal-anti-aliasing">Temporal Anti-Aliasing</span>
    <hr>
</div>

TAA works by slightly jittering the view frustum each frame to gather more scene information and then blending the current frame with previous frames using a history buffer. I talk more about TAA in [this](/posts/Fixing-Real-Time-Optimizations-For-Volumetric-Rendering/) post. In the first iteration of this project, I attempted to apply TAA solely to the output of the outline pass, but this approach didn't work as expected. The resulting image continued to jitter along the edges of objects. I believe this issue stems from the TAA algorithm **[1](#INSIDE)** I implemented, as it likely requires the full context of the image to properly accumulate data across multiple frames.

To implement multiple render targets, I followed Unity's example code from the URP's Render Graph sample package **[2](#URPPackageSamples)**. While this approach works for cases that only use TextureHandle objects for output attachments, it didn’t work in my case where I needed to pass the output history buffer back to the input. Render Graph does not allow a TextureHandle to be used as both an input and output attachment in the same pass, so I had to copy the data to an intermediate texture.

The issue arose when using the _ImportTexture()_ function with a RenderTexture, as it didn’t generate a valid texture descriptor, resulting in errors when attempting to copy data from the imported texture. Ultimately, I switched to directly creating RTHandles in the _SetUp()_ function, as shown below:


<div class="padded-code-block">
{% highlight C# %}
Material m_Material;
RTHandle[] m_RTs = new RTHandle[2];
TemporalReprojection m_temporalReprojection;

public void Setup(Material material, TemporalReprojection temporalReprojection)
{
    m_Material = material;
    m_temporalReprojection = temporalReprojection;

    RenderTextureDescriptor textureProperties = new RenderTextureDescriptor(Screen.width, Screen.height, RenderTextureFormat.Default, 0);
    RenderingUtils.ReAllocateIfNeeded(ref m_RTs[0], textureProperties, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "TRHistoryBuffer" );
    RenderingUtils.ReAllocateIfNeeded(ref m_RTs[1], textureProperties, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "TRScreenBuffer" );
}
{% endhighlight %}
</div>

In the first render pass, I copy the history buffer draw to a texture that I share between passes using the Blitter.BlitTexture() function. 

<div class="padded-code-block">
{% highlight C# %}
using (var builder = renderGraph.AddRasterRenderPass<BlitPassData>("Copy TR History Texture", out var passData))
{   
    // Fetch the texture from the frame data 
    var customData = frameData.Get<AddOwnTexturePass.CustomData>();
    var historyBackBuffer = customData.newTextureForFrameData;

    if(!historyBackBuffer.IsValid() || !handles[0].IsValid())
    {
        Debug.LogError("Temporal Reprojection: Invalid texture handle.");
        return;
    }

    builder.SetRenderAttachment(historyBackBuffer, 0, AccessFlags.Write);

    // Add the texture to the pass data
    passData.textureToRead = handles[0];
    passData.material = m_Material;

    // Set the texture as readable
    builder.UseTexture(passData.textureToRead, AccessFlags.ReadWrite);

    builder.AllowPassCulling(false);

    builder.SetRenderFunc((BlitPassData data, RasterGraphContext rgContext) => 
    {
        Blitter.BlitTexture(rgContext.cmd, data.textureToRead, new Vector4(1.0f,1.0f,0,0), 0, false);
    });
}
{% endhighlight %}
</div>

And then in the actual TAA render pass, I read from the history buffer copy, setting it as an input attachement along with the active depth, color, and motion vectors, which are all just apart of the UniversalResourceData.

<div class="padded-code-block">
{% highlight C# %}
using (var builder = renderGraph.AddRasterRenderPass<PassData>(m_PassName, out var passData))
{
    // Fetch the universal resource data to exstract the camera's color attachment.
    var resourceData = frameData.Get<UniversalResourceData>();

    // Fetch the texture from the frame data 
    var customData = frameData.Get<AddOwnTexturePass.CustomData>();
    var historyBackBuffer = customData.newTextureForFrameData;

    if(!historyBackBuffer.IsValid() || !handles[0].IsValid())
    {
        Debug.LogError("Temporal Reprojection: Invalid texture handle.");
        return;
    }
    
    // Use the camera's color attachment as input.
    passData.color = resourceData.activeColorTexture;
    passData.texName_color = m_texName_color;
    
    // Use the camera's depth attachment as input.
    passData.depth = resourceData.activeDepthTexture;
    passData.texName_depth = m_texName_depth;

    // Use the customData historyBackBuffer as input since we cant both read a texture that we set as one of the render targets.
    passData.history = historyBackBuffer;
    passData.texName_history = m_texName_history;

    // Use the camera's motion vectors attachment as input.
    passData.motionvectors = resourceData.motionVectorColor;
    passData.texName_motionvectors = m_texName_motionvectors;


    // Material used in the pass.
    passData.material = m_Material;


    SetMatieralProperties(passData.material, Screen.width, Screen.height);

    // Sets input attachments.
    builder.UseTexture(passData.color);
    builder.UseTexture(passData.depth);
    builder.UseTexture(passData.history);
    builder.UseTexture(passData.motionvectors);

    // Sets color attachments.
    for (int i = 0; i < 2; i++)
    {
        builder.SetRenderAttachment(handles[i], i);
    }

    // Sets the render function.
    builder.SetRenderFunc((PassData data, RasterGraphContext rgContext) => ExecutePass(data, rgContext));

    resourceData.cameraColor = handles[1];
}

static void ExecutePass(PassData data, RasterGraphContext rgContext)
{
    // Sets the input color texture to the name used in the MRTPass
    data.material.SetTexture(data.texName_color, data.color);
    data.material.SetTexture(data.texName_depth, data.depth);
    data.material.SetTexture(data.texName_history, data.history);
    data.material.SetTexture(data.texName_motionvectors, data.motionvectors);
    
    // Draw the fullscreen triangle with the MRT shader.
    rgContext.cmd.DrawProcedural(Matrix4x4.identity, data.material, 0, MeshTopology.Triangles, 3);
}
{% endhighlight %}
</div>

<div class="reusable-divider">
    <span class="small-header-text" id="Ensuring-TAA-Compatibility">Ensuring TAA Compatibility with the Outline Shader</span>
    <hr>
</div>


The outline shader relies on both normal and depth information for edge detection. After jittering the projection matrix, the shader no longer functions correctly when using Shader Graph nodes for scene depth or normals. Through experimentation with the  UniversalResourceData **[6](#UniversalResourceData)** and RenderDoc, I found that the outline shader works only with the activeDepthBuffer and not with the _cameraDepthTexture_. I suspect this is because Shader Graph nodes sample the _cameraDepthTexture_ and _cameraNormalTexture_, which are written during the pre-passes that occur before the projection matrix is modified. 

Since there is no activeNormalsBuffer equivalent, I have to execute a _DrawRendererList_ for the objects in the outline layer using a material that outputs view-space normal information. This pass is performed immediately before the outline-drawing pass to ensure the correct normals are captured after the projection matrix is jittered.

This approach works but is not the most performant solution, as it requires an additional draw call for all objects in the outline layers to capture view-space normals. Ideally, the shader responsible for writing to the active depth and color textures could also be extended to output an activeNormalsBuffer, eliminating the need to re-render geometry for the normal pass. However, this would likely require implementing a custom Scriptable Render Pipeline (SRP), which I did not want to do for this project.


<div class="reusable-divider">
    <span class="small-header-text" id="non-maximum-suppression">Non-Maximum Suppression</span>
    <hr>
</div>



As described in the article by FIVEKO **[5](#NMS)**, Non-Maximum Suppression (NMS) is an algorithm that enhances edge detection techniques by identifying the local peaks along edge lines. It achieves this by comparing the gradient magnitude and orientation of a pixel with those of its neighbors. If the current pixel's intensity is lower than that of any of its neighbors, it is suppressed, meaning its value is set to zero. This process significantly reduces false edge detections, such as those caused by very steep (view-normal) angles, as demonstrated in the following images:

![outlines_nms_example](/assets/Images/ScreenSpaceOutlines/outlines_nms_example.PNG){: .default-image .clickable-image}

<div class="custom-image-description">
The left image shows edge detection without NMS, while the right image demonstrates the effect of applying NMS.
</div>


To implement NMS, it is necessary to calculate both the gradient magnitude and the gradient direction. These calculations resemble convolution operations commonly used in image processing. In this implementation, the Roberts Cross operator is used. This operator performs a similar function to the Sobel operator by approximating the gradient at each pixel but is more computationally efficient, requiring only 4 samples per pixel compared to Sobel's 9.

<div class="padded-code-block">
{% highlight hlsl %}
#ifndef ROBERTS_CROSS
#define ROBERTS_CROSS

    void RobertsCross_float(
        float DepthTopRight,
        float DepthBottomLeft,
        float DepthTopLeft,
        float DepthBottomRight,
        float RobertsCrossMultiplier,
        out float gradientMagnitude,  // Output: Gradient magnitude
        out float gradientDirection   // Output: Gradient direction
        )
    {
        float Gx = (DepthTopRight - DepthBottomLeft) * (DepthTopRight - DepthBottomLeft);
        float Gy = (DepthTopLeft - DepthBottomRight) * (DepthTopLeft - DepthBottomRight);

        // Gradient magnitude
        gradientMagnitude = sqrt(Gx + Gy) * RobertsCrossMultiplier;

        // Gradient direction in degrees
        gradientDirection = atan2(Gy, Gx) * (180.0 / 3.14159265359); // Convert radians to degrees since we specifically use degrees in the NonMaxSuppression function
    }

    void RobertsCrossViewSpaceNormals_float(
        float2 UVTopRight,
        float2 UVBottomLeft,
        float2 UVTopLeft,
        float2 UVBottomRight,
        UnityTexture2D _ViewSpaceNormalsTexture, 
        UnitySamplerState _ViewSpaceNormalsSampler, 
        out float4 sampleAlpha,
        out float gradientMagnitude,  // Output: Gradient magnitude
        out float gradientDirection   // Output: Gradient direction
        )
    {
        float4 vsn_0 = _ViewSpaceNormalsTexture.Sample(_ViewSpaceNormalsSampler, UVTopRight);
        float4 vsn_1 = _ViewSpaceNormalsTexture.Sample(_ViewSpaceNormalsSampler, UVBottomLeft);
        float4 vsn_2 = _ViewSpaceNormalsTexture.Sample(_ViewSpaceNormalsSampler, UVTopLeft);
        float4 vsn_3 = _ViewSpaceNormalsTexture.Sample(_ViewSpaceNormalsSampler, UVBottomRight);

        float3 v_0 = vsn_0.xyz - vsn_1.xyz;
        float3 v_1 = vsn_2.xyz - vsn_3.xyz;

        sampleAlpha = float4(vsn_0.a, vsn_1.a, vsn_2.a, vsn_3.a);

        // Compute gradient components
        float Gx = dot(v_0, v_0);
        float Gy = dot(v_1, v_1);

        // Gradient magnitude
        gradientMagnitude = sqrt(Gx + Gy);

        // Gradient direction in degrees
        gradientDirection = atan2(Gy, Gx) * (180.0 / 3.14159265359); // Convert radians to degrees
    }

#endif
{% endhighlight %}
</div>

As shown above, the outline shader uses the two Roberts Cross operators on both the depth and normals textures to detect edges that either method alone might miss. Combining these two methods involves calculating a unified gradient magnitude and direction. For the gradient magnitude, I take the maximum value between the two calculations to emphasize the strongest edge. For the gradient direction, I compute a weighted average of the two directions. The resulting combined gradient is then stored in the output texture, with the gradient magnitude written to the red channel and the gradient direction to the green channel.

![outlines_pass_output](/assets/Images/ScreenSpaceOutlines/outlines_pass_output.PNG){: .default-image .clickable-image}

<div class="padded-code-block">
{% highlight hlsl %}

    void ComputeCombinedGradient_float(
        float depthGradientMagnitude,
        float depthGradientDirection,
        float vsnGradientMagnitude,
        float vsnGradientDirection,
        out float combined_gradientMagnitude,
        out float combined_gradientDirection)
    {
        combined_gradientMagnitude = max(depthGradientMagnitude, vsnGradientMagnitude);
        
        // Smoothly blend gradient directions based on their magnitudes
        float totalMagnitude = depthGradientMagnitude + vsnGradientMagnitude;
        if (totalMagnitude > 0.0)
        {
            combined_gradientDirection = (depthGradientDirection * depthGradientMagnitude + 
                                        vsnGradientDirection * vsnGradientMagnitude) / totalMagnitude;
        }
        else
        {
            combined_gradientDirection = 0.0; // Default value if both gradients are zero
        }
    }

{% endhighlight %}
</div>




In a subsequent shader pass, I sample only the red channel of the outline texture if NMS is not needed. However, if NMS is enabled, I use both the red (magnitude) and green (direction) channels to perform the suppression step.

![NMS_2](/assets/Images/ScreenSpaceOutlines/NMS_2.PNG){: .default-image .clickable-image}

Here is the function responsible for determining if a pixel is a local maximum. As previously described, it compares the current pixel's strength with the strengths of its neighbors along the gradient direction:

<div class="padded-code-block">
{% highlight hlsl %}

    float2 sample_edge(UnityTexture2D _tex, UnitySamplerState _sampler, float2 uv)
    {
        return _tex.Sample(_sampler, uv).rg;
    }

    void NonMaxSuppression_float(
        float2 uv_0,
        float2 texelSize,
        float offsetScale,
        UnityTexture2D _EdgeTexture, 
        UnitySamplerState  _EdgeSampler, 
        out float nms_output)
    {   

        float angle = sample_edge(_EdgeTexture, _EdgeSampler, uv_0).g;
        
        if(angle < 0)
            angle += 180;

        float v_0 = sample_edge(_EdgeTexture, _EdgeSampler, uv_0).r;

        float q = 255;
        float r = 255;
        
        if ((0 <= angle && angle < 22.5) || (157.5 <= angle && angle <= 180))
        {
            angle = 0;

            float2 uv_1 = uv_0 + float2(0, 1) * texelSize * offsetScale;
            float2 uv_2 = uv_0 + float2(0, -1) * texelSize * offsetScale;

            q = sample_edge(_EdgeTexture, _EdgeSampler, uv_1).r;
            r = sample_edge(_EdgeTexture, _EdgeSampler, uv_2).r;
        }
        else if (22.5 <= angle && angle < 67.5)
        {
            angle = 45;

            float2 uv_1 = uv_0 + float2(1, -1) * texelSize * offsetScale;
            float2 uv_2 = uv_0 + float2(-1, 1) * texelSize * offsetScale;

            q = sample_edge(_EdgeTexture, _EdgeSampler, uv_1).r;
            r = sample_edge(_EdgeTexture, _EdgeSampler, uv_2).r;
        }
        else if (67.5 <= angle && angle < 112.5)
        {
            angle = 90;

            float2 uv_1 = uv_0 + float2(1, 0) * texelSize * offsetScale;
            float2 uv_2 = uv_0 + float2(-1, 0) * texelSize * offsetScale;

            q = sample_edge(_EdgeTexture, _EdgeSampler, uv_1).r;
            r = sample_edge(_EdgeTexture, _EdgeSampler, uv_2).r;
        }
        else if (112.5 <= angle && angle < 157.5)
        {
            angle = 135;

            float2 uv_1 = uv_0 + float2(-1, -1) * texelSize * offsetScale;
            float2 uv_2 = uv_0 + float2(1, 1) * texelSize * offsetScale;

            q = sample_edge(_EdgeTexture, _EdgeSampler, uv_1).r;
            r = sample_edge(_EdgeTexture, _EdgeSampler, uv_2).r;
        }


        
        // if v_0 is greater than both q and r, then it is a local maximum. If it is not, 
        // then we suppress it by setting the value to 0 in order to thin the edges. 
        if ((v_0 >= q) && (v_0 >= r))
            nms_output = v_0;
        else
            nms_output = 0;
    }

{% endhighlight %}
</div>

<div class="reusable-divider">
    <span class="small-header-text" id="future-work">Future Work:</span>
    <hr>
</div>

In the near future, I plan to expand the outline shader by adding support for multiple edge detection methods and allowing for multiple outline layers with different colors to provide more flexibility and customization, to where it could potentially be used for something like an item tier system, such as in Risk of Rain 2.


<div class="reusable-divider">
    <span class="small-header-text" id="links">LINKS</span>
    <hr>
</div>

1. [Temporal Reprojection Anti-Aliasing in INSIDE](https://s3.amazonaws.com/arena-attachments/655504/c5c71c5507f0f8bf344252958254fb7d.pdf?1468341463){: #INSIDE}
2. [URP Package Samples](https://docs.unity3d.com/6000.0/Documentation/Manual/urp/package-sample-urp-package-samples.html){: #URPPackageSamples}
3. [RobinSeibold, Outlines - Devlog 2](https://www.youtube.com/watch?v=LMqio9NsqmM&ab_channel=RobinSeibold){: #RSVideo}
4. [RobinSeibold Outlines Github Repository](https://github.com/Robinseibold/Unity-URP-Outlines){: #RSGithub}
5. [Article on Gradient Non-Maximum Suppression by FIVEKO](https://fiveko.com/blog/non-maximum-suppression-gradient/){: #NMS}
6. [URP UniversalResourceData](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/api/UnityEngine.Rendering.Universal.UniversalResourceData){: #UniversalResourceData}


[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
