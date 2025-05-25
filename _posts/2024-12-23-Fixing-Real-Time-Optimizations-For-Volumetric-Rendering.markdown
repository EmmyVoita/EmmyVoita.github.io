---
layout: custom-post
title: Volumetric Rendering<br>Real-Time Optimizations
date: 2024-12-22 00:00:00 -0700
permalink: /posts/Real-Time-Optimizations-For-Volumetric-Rendering/
image: /assets/Images/Sprint 6/CLOUDS IMAGE_1.png
description: >
    Implementing temporal reprojection, temporal anti-aliasing, and temporal upsampling to improve performance and visual quality in volumetric cloud and atmosphere rendering.
categories: jekyll update main
tags: [Unity, Volumetric Rendering]
#priority: 3
---


![2024-10-1517-57-42-ezgif com-optimize](/assets/videos/Clouds/2024-10-1517-57-42-ezgif.com-optimize.gif){: .center .add-spacing .image-with-shadow} 


* [Overview](#overview)
* [Implementing Temporal Anti-Aliasing](#implementing-taa)
* [Implementing Temporal Upsampling](#implementing-tu)
* [Results](#results)
* [Future Work](#future-work)
* [Resources](#resources)


<div class="reusable-divider">
    <span class="small-header-text" id="overview">Overview</span>
    <hr>
</div>

In real-time rendering, achieving high-quality visuals while maintaining performance is a constant challenge. This is especially relevant for volumetric rendering or any algorithm that utilizes raymarching, raytracing, or path tracing. To achieve acceptable real-time performance, many implementations employ techniques like Temporal Anti-Aliasing (TAA) and temporal upsampling, which enable rendering at lower resolution  while using past frames to achieve acceptable image quality. In this project, I implemented a TAA and TU solution in HLSL, integrating edge-aware filtering to improve stability and clarity.

I had previously attempted to implement TAA but was unsuccessful due to a flawed understanding of how to manage rendering across multiple frames.  Coming back to this project after a break, I decided to do more research on how to effictivley implement Temporal Reprojection and Temporal Anti-Aliasing in a volumetric rendering setting. I found this blog post **[4](#VertexFragmentUpsampling)**, which described that rather than drawing 1/16 of the image onto a full resolution buffer per frame (which was what i was previously doing), to instead draw to a quarter resolution buffer and upsample the image in a following pass. To implement this change, I removed the logic that determined which texel to draw to each frame (previously drawing one pixel and skipping 15) and changed the output buffer to quarter resolution.


<div class="reusable-divider">
    <span class="small-header-text" id="implementing-taa">Implementing Temporal Anti-Aliasing</span>
    <hr>
</div>


At first I ended up just having a very simple reprojection shader that was just a modification of the implementation described in the aforementioned blog **[4](#VertexFragmentUpsampling)**, which had ok results, but didn't really improve image quality all that much. I used this code for a while.

<div class="padded-code-block">
{% highlight hlsl %}
float JitterCorrection2(float2 uv)
{
    float2 localIndex = floor(fmod(uv * _Resolution, 4.0f));
    localIndex = abs(localIndex - _FrameJitter);
    return saturate(localIndex.x + localIndex.y);
}

float JitterCorrection4(float2 uv)
{
    float2 localIndex = floor(fmod(uv * _Resolution, 4.0f));
    float2 diff = localIndex - _FrameJitter;
    float variance = dot(diff, diff) / 2.0f; // Calculate variance
    float standardDeviation = sqrt(variance); // Calculate standard deviation
    return saturate(1.0f - standardDeviation);
}

float jitterCorrection = JitterCorrection4(i.ss_txc);
float jitterCorrection2 = JitterCorrection2(i.ss_txc);
jitterCorrection = lerp(jitterCorrection, jitterCorrection2, 0.2);

// Sample the texture
float4 prevColor = tex2D(_PrevFrameColor, i.ss_txc);
float4 currColor = tex2D(_MainTex, i.ss_txc);
float4 jitteredColor = lerp(prevColor, currColor, .1);

// Move UV (0, 0) to the center and get the distance from the zenith
float2 normalizedUV = (i.ss_txc * 2.0f) - 1.0f;                           
float distanceFromZenith01 = saturate(length(normalizedUV));

// Arbitrary convergance speeds. 
float converganceSpeedZenith = 0.75f;                               
float converganceSpeedHorizon = 0.5f;
float converganceSpeed = lerp(converganceSpeedZenith, converganceSpeedHorizon, distanceFromZenith01);

float4 finalColor = lerp(prevColor, jitteredColor, converganceSpeed);
{% endhighlight %}
</div>

<div class="custom-image-description">
I ended up trying different methods for jitter correction, which is what JitterCorrection2 and JitterCorrection4 are. I found that blending between those two jitter correction methods worked the best in my case.
</div>


While working on my [Screen Space Outlines](/posts/Unity-URP-Screen-Space-Outlines/) so that I could implement it into a school project, I was looking for anti-aliasing techniques and decided that I would try again at implementing TAA. I came across public code by PlayDeadGames for their impelmentation of TAA, and decided that I would try and implement that into this project which was straight forward for the most part. I just needed to implement a motion vector buffer. 

A common approach to calculate motion vectors is to use the world position. This method utilizes maintaining a reference to the view-projection matrix of the previous frame to convert the world position to clip space for the previous frame and current frame. The motion vector is then the difference in clip space position between frames, which represents how much that position moved between frames. 

<div class="padded-code-block">
{% highlight hlsl %}
void UpdateMotionVectors(uint3 id, float3 estimatedWorldPos)
{
    
    float2 motionVector = float2(0, 0);
    float4 worldPosCurrnt = float4(estimatedWorldPos.xyz, 1.0);

    float4 curClipPos = mul(_currViewProjMatrix, worldPosCurrnt);
    float4 prevClipPos = mul(_prevViewProjMatrix, worldPosCurrnt);

    float2 previousPositionCS = prevClipPos.xy / prevClipPos.w;
    float2 positionCS = curClipPos.xy / curClipPos.w;

    motionVector = (positionCS - previousPositionCS) * 0.5; 
    MotionVectorBuffer[id.xy] = motionVector;
}
{% endhighlight %}
</div>

It took some time to figure out how to accurately calculate the world position. Obtaining the world position for the clouds, however, was relatively straightforward since I had previously implemented this when working on temporal reprojection. The process involves determining the position of the cloud by calculating the average density along a given ray. To achieve this, I compute a weighted sum of the density at each cloud sample. After raymarching, I compute the average of these values to determine the depth position, which is then used to calculate the world position. The following shows the accumulation of cloud density during the raymarching process.

<div class="padded-code-block">
{% highlight hlsl %}

float weightedSum = 0.0;
float accumulatedWeight = 0.0;

//Ray Marching Loop
//---------------------------------------------------------------

    // If we are taking a cloud sample

        // Accumulate the weighted sum of the sample position to calculate the center of the cloud.
        float weight = cloudDensityRaw * cloudSmallStepSize;
        weightedSum += (dstTraveled + ray_length.x) * weight;
        accumulatedWeight += weight;

//---------------------------------------------------------------
{% endhighlight %}
</div>

Here are the calculations I perform after raymarching. I encountered a lot of challenges when determining how to handle the atmosphere's world position. For TAA to work correctly I had to take into account the atmosphere, otherwise motion on the edges of clouds would not be captured correctly. Initially, I tried using the same sampling method that I used for the cloud world position, where I compute a weighted sum of the density. However, I ran into several issues with that approach. It's been a while since I debugged it, so I don't recall the exact problems, but the solution I settled on was setting the depth value to the far plane when the accumulated weight is very small. Since I'm not accumulating any weight while sampling the atmosphere, if a ray only samples the atmosphere, the accumulated weight will be zero, and thus, the depth value is set to the far plane. 

<div class="padded-code-block">
{% highlight hlsl %}
float depth = (weightedSum / accumulatedWeight);
float atmoDepth = farPlane; 

float3 estimatedWorldPosition;
float combinedDepth;

if(accumulatedWeight <= 1.0)
{
    combinedDepth = atmoDepth;
}
else
{
    combinedDepth = depth;
}

combinedDepth = min(combinedDepth, max_dist);

// Here if i need to use just cloud motion vectors swap this out
estimatedWorldPosition = rayOriginRaw + ray_direction * combinedDepth;

outDepth = combinedDepth;
outWorldPos = estimatedWorldPosition;
{% endhighlight %}
</div>


<!-- 
Another key aspect of implementing Temporal AA and upsampling, which I discussed in [this](/posts/Attempting-Optimizing-Volumetric-Rendering-with-Temporal-Techniques/)  previous post, is jittering the view frustum. As explained in the GDC presentation "Temporal Reprojection Anti-Aliasing in INSIDE" **[4](#INSIDE)**, rendering at a lower resolution results in a loss of detail. Jittering the view frustum helps recover that lost information over time by slightly shifting the sampling position each frame. By maintaining a reference to the previous frame using an additional render texture, we can combine information from both the current and previous frames, improving image stability and quality.
-->

Another key aspect of implementing Temporal AA and upsampling is jittering the view frustum. As explained in the GDC presentation "Temporal Reprojection Anti-Aliasing in INSIDE" **[4](#INSIDE)**, rendering at a lower resolution results in a loss of detail. Jittering the view frustum helps recover that lost information over time by slightly shifting the sampling position each frame. By maintaining a reference to the previous frame using an additional render texture, we can combine information from both the current and previous frames, improving image stability and quality.


![Jitter](/assets/Images/Post 6/Doccumentation_6_1.png){: .center .add-small-spacing .image-with-shadow}

For my compute shader I implement jittering the view frustum by computing the jittered UV and using the jittered UV to create the camera ray that I use for raymarching. Ill go over why I use the "frac(bayer16(id.xy)+float(frame)/float2(phi2*phi2,phi2))" for computing the Jitter UV later. 

<div class="padded-code-block">
{% highlight hlsl %}
Ray CalculateJitteredRay(uint2 id, uint width, uint height, int frame)
{
    float2 uvJitter = frac(bayer16(id.xy)+float(frame)/float2(phi2*phi2,phi2));

    // Calculate the jittered UV coordinates
    float2 jitteredUV = (id.xy + uvJitter) / float2(width, height);

    // Clamp the UV coordinates to the [0, 1] range
    jitteredUV = clamp(jitteredUV, 0.0, 1.0);

    // Centered normalized UV for ray marching
    float2 centeredNormalizedUV = jitteredUV * 2.0f - 1.0f;

    // Get a ray for the UV
    Ray ray = CreateCameraRay(centeredNormalizedUV, _CameraToWorld, _CameraInverseProjection);

    return ray;
}
{% endhighlight %}
</div>


With the TAA pass, we would typically counteract the jitter when sampling the current frame texture. In my case, I have a temporal upsampling pass that produces a final output with jittering resolved by blending and filtering over time, so I don't need to unjitter when I sample my current frame texture in the TAA pass.  

<div class="padded-code-block">
{% highlight hlsl %}
#if UNJITTER_COLORSAMPLES
    float4 texel0 = sample_color(_CurrTexSampler, ss_txc - _JitterUV.xy);
#else
    float4 texel0 = sample_color(_CurrTexSampler, ss_txc);  
#endif
{% endhighlight %}
</div>

I ignored implementing a TU pass while I implemented TAA, because I wanted to tackle TU last. 
While impelmenting TAA, I ran into issues with flickering, which was especially noticable along the edges of clouds. 

![2024-09-2819-47-16-ezgif com-optimize](/assets/videos/Clouds/2024-09-2819-47-16-ezgif.com-optimize.gif){: .center .add-spacing .image-with-shadow} 

I spent a lot of time modifying my implementation of PlayDeadGames' TAA code 4 to resolve the flickering issue. I found that the problem was due to how I was using blue noise to offset the sampling position of a ray in my compute shader. This technique is a common optimization in real-time volumetric rendering, where fewer raymarching steps are required while maintaining similar quality.  However, on the edges of clouds, where fine details exist and fewer samples intersect, offsetting the sample position can introduce greater variance in the output color. For example, in one frame, a ray may intersect the cloud, while in the next, it might miss the cloud and return the atmosphere color. Normally, this variance is not a problem when blending the output image with the previous frame over time. However, with TAA, we aim to constrain the history sample, as the history can become invalid. Two methods to address this are neighborhood clipping and neighborhood clamping, which constrain the history sample by taking a min and max of surrounding texels, and then using the min and max, clipping and clamping in color space respectivley. Both of these methods target large variance in an image caused by artifacts like noise or sudden changes in motion, which is problematic when we know that there is going to be significant variance due to the raymarching offset. 

I spent a lot of time experimenting with different methods to fix this issue. Initially, I thought I needed to modify my constraint algorithm, so I implemented adaptive clipping. This approach aimed to constrain less in scenarios with low motion or low luminance variance, while constraining more in higher motion areas. My idea was that I could mask the flickering in high-motion areas by using motion blur, since the adaptive clipping would provide stronger constraints in those areas. While this approach somewhat worked, it was too finicky and heavily dependent on fine-tuning values through constant trial and error. For example, I struggled to remap the velocity from my motion vector texture to a usable range that would allow the clipping to adapt dynamically to the camera's movement speed. I also experimented with denoising algorithms, but I couldn't get them to produce reliable results.


<div class="padded-code-block">
{% highlight hlsl %}
float4 adaptive_clip_aabb(
    float4 cmin, 
    float4 cmax, 
    float4 cavg, 
    float4 texel0, 
    float4 texel1, 
    float4 filteredTexel0, 
    float4 filteredTexel1, 
    float velocity_magnitude)
{
    float lum_current = Luminance(filteredTexel0);
    float lum_prev = Luminance(filteredTexel1);

    float luminance_variance = abs(lum_current - lum_prev);
    
    float remapped_velocity = remap_velocity(velocity_magnitude, 0.0, 1.0, 0.0, 10.0);
    float amplified_velocity = pow(remapped_velocity, 2);

    float threshold = lerp(0.1, 0.0, saturate(amplified_velocity)); 

    if (luminance_variance < threshold) {
        luminance_variance = 0.0;
    } 

    float weighted_variance = sqrt(luminance_variance);

    // Compute a dynamic confidence factor based on motion and luminance variance
    float confidence = 1.0 - saturate(amplified_velocity + weighted_variance);
    
    // Soft blend instead of hard clamp
    float4 blended_color = lerp(clip_aabb(cmin.xyz, cmax.xyz, clamp(cavg, cmin, cmax), texel1), texel1, confidence);

    return blended_color;
}
{% endhighlight %}
</div>

While searching for solutions to the problem, I came across a blog post 4 that described Interleaved Gradient Noise (IGN) and how it improves TAA by making the area sampled during neighborhood clipping/clamping more accurately represent the full range of possible pixel values. I implemented IGN into my compute shader, which gave good results, significantly reducing flickering. However, I found that in exchange, the noise pattern in my clouds became more noticeable, particularly for distant clouds. I experimented with lowering the influence of the noise on cloud samples, which reduced noise visibility slightly, but as the influence decreased, the low raymarching sample count became more apparent, so this wasn’t a viable solution. At some point, I came across (possibly in a conversation with AI) the idea that temporal upsampling should help reduce the amount of noise in the image. This made sense, as blending between surrounding texels and the history would smooth out the noise.


<div class="reusable-divider">
    <span class="small-header-text" id="implementing-tu">Implementing Temporal Upsampling</span>
    <hr>
</div>


My first attempt at implementing Temporal Upsampling involved following the approach outlined on pages 7-9 of  _A Survey of Temporal Antialiasing Techniques_ **[4](#TAASurvey)**. The method describes upscaling input samples to the target resolution using a reconstruction filter (e.g., Gaussian or box kernel) and computting a confidence factor for each pixel to determine the quality of the upscaled sample. Then, high-confidence upscaled samples are blended with historical data using temporal accumulation.

I also came across articles **[10](#UnrealEngineTAAU)**,**[11](#UnrealEngineTemporalUpscale)**  that describe implementing Temporal Anti-Aliasing and Temporal Upsampling in the same shader, referred to as TAAU. I struggled with understanding how this is done. When trying to implement the method described in _A Survey of Temporal Antialiasing Techniques_ to perform TU within the same pass as TAA, I encountered what seemed to be a circular dependency. That is, TAA relies on TU, but TU also relies on the constrained history from TAA. I believe now that the issue is due to trying to apply TU before TAA, when it should be applied after. Anyways, after getting stuck on it for a while, and not being able to find information on it that helped, I spent more time trying to find some example implementation of TU or TAAU. I came across this shadertoy **[7](#TemporalWaveletShaderToy)** and after analyzing how it works, I decided to try to implement that approach as a pass that happens before TAA. 


The approach uses a "bayer16" function that acts as a low-discrepancy noise generator, producing pseudo-random values for each input value (UV coordinates). This noise offsets the sampling position of the input low-resolution image, changing with each frame based on the current frame number. The upsampling shader samples the 3x3 neighborhood, recalculating the offset for each sample. A weight value for the current sampled pixel is calculated based on the offset distance from the current pixel position and "k," which controls the balance between sharpness and smoothing in the output image. The weighted sample is accumulated for each pixel in the 3x3 neighborhood and combined with the previous frame to produce the final output. I believe this implementation follows the approach described in the previously mentioned paper 4, where the weight value "w" acts as a confidence factor. In my implementation, I slightly modify this by introducing depth sampling to preserve sharpness near cloud edges.

<div class="padded-code-block">
{% highlight hlsl %}
float4 TemporalUpSample(sampler2D _currSampler, sampler2D _DepthBuffer, float4 _CurrTexelSize, float4 _InputTexelSize, float4 historySample, float2 uv, float RENDERSCALE, int iFrame, float2 ss_vel)
{
    
    float2 I2 = RENDERSCALE * (uv * _CurrTexelSize.zw);

    float k = 80.; // Defines the sharpness of the filtering (used for Gaussian-like smoothing)
    int kernell = 1;   // Size of the filter kernel. A kernel size of 1 means a 3x3 neighborhood (one pixel around the center pixel). This can be increased for more smoothing.


    // The temporal blending factor that depends on the current frame number (iFrame). 
    // This value determines how much weight is given to the current frame compared to the previous frame.
    float s = min(acos(-1.) / k * float(iFrame), 2.0);

    float4 O = historySample * s;

    float4 cmin = float4(1.0, 1.0, 1.0, 1.0);
    float4 cmax = float4(0.0, 0.0, 0.0, 0.0);
    float4 sum = float4(0.0, 0.0, 0.0, 0.0);

    float depthCenter = tex2D(_DepthBuffer, uv).r;
    float maxDepthDifference = 0.0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float2 c = float2((float)x, (float)y);  // Loop through neighboring texels

            float2 offset = frac(bayer16(I2+c)+float(iFrame)/float2(phi2*phi2,phi2))+c;

            #if 1
                //larger kernell if no temporal data to avoid dark spots
                float w = exp2(-(iFrame==0?.25/RENDERSCALE:k)*dot2(offset-frac(I2)));
            #else 
                //sinc-based variant
                float w = lacnzos(k*length(offset-frac(I2)),float(kernell+1));
            #endif

            float2 uvCurrSample = (I2 + c) / _InputTexelSize.zw;
            uvCurrSample = clamp(uvCurrSample,0,1);
            float4 t = sample_color(_currSampler, uvCurrSample);

            // Sample depth buffer
            float depthCurr = tex2D(_DepthBuffer, uvCurrSample).r;
            maxDepthDifference = max(maxDepthDifference, abs(depthCurr - depthCenter));

            cmin = min(cmin, t);
            cmax = max(cmax, t);
            sum += t;
            
            O+=t*w;
            s+=w;
        }
    }

    float4 cavg = sum / 9.0; // Average color of the 3x3 neighborhood
    
    // Apply softer neighborhood clipping
    float4 clampedO = clamp(O / s, cmin, cmax);

    // Edge-aware filtering using depth difference
    float edgeThreshold = 0.05; 
    bool isEdge = maxDepthDifference > edgeThreshold;
    float blendFactor = isEdge ? 0.8 : 0.2; //A higher blend factor for edges to retain more detail

    O = lerp(O / s, clampedO, blendFactor);
    O = resolve_color(O);
    
    return O;
}           
{% endhighlight %}
</div>

![2024-10-1517-57-42-ezgif com-optimize](/assets/videos/Clouds/2024-10-1517-57-42-ezgif.com-optimize.gif){: .center .add-spacing-with-description .image-with-shadow} 

<div class="custom-image-description">
As mentioned previously, a 1/4th resolution input buffer is typically used when upsampling volumetrics. In this case, I am using a 1/16th resolution input buffer to more clearly show the upsampling difference. 
</div>



* [IncTemporalUpsampling.hlsl](/assets/files/IncTemporalUpsampling.hlsl)
* [Upsample Shader](/assets/files/UnlitUpSample.shader)

<div class="reusable-divider">
    <span class="small-header-text" id="results">Results</span>
    <hr>
</div>

These optimizations significantly reduced frame times while preserving acceptable visual quality. Rendering at full resolution, the average frame time using an NVIDIA GeForce GTX 1070 was 16.3ms, whereas rendering at 1/4 scale reduced it to 4.8ms, a 3.4x improvement. Despite the reduced step count and smaller output buffer, aliasing and flickering remained unnoticeable due to the integration of Temporal Anti-Aliasing (TAA).

To balance performance and quality, the raymarching algorithm was configured as follows:

* **Cloud rendering:** 32 primary steps, 6 light steps, 1 light source
* **Atmospheric rendering:** 12 steps

| Render Scale | Frame Time | 
|----------|----------|
| 1        | 16.3ms   | 
| 1/2      | 7.75ms   | 
| 1/4      | 4.8ms    |
| 1/8      | 3.25ms   | 

<div class="custom-image-description">
Frame time varies depending on the viewer's perspective. To account for this, the listed values are averaged between the worst-case scenarios for horizontal and vertical viewpoints. 
</div>


<div class="reusable-divider">
    <span class="small-header-text" id="future-work">Future Work</span>
    <hr>
</div>

I am working on moving this project to the URP pipeline. In the next post about this project, I will talk about the improvements I made to cloud visual quality, scene compositing, and the changes required for URP. I also plan to switch the atmosphere samples to utilize a LUT, as explained in _A Scalable and Production Ready
Sky and Atmosphere Rendering Technique_ **[12](#sebastien)**. 


<div class="reusable-divider">
    <span class="small-header-text" id="resources">LINKS</span>
    <hr>
</div>

1. [Temporal Reprojection Anti-Aliasing in INSIDE](https://s3.amazonaws.com/arena-attachments/655504/c5c71c5507f0f8bf344252958254fb7d.pdf?1468341463){: #INSIDE}
2. [Upsampling to Improve Volumetric Cloud Render Performance](https://www.vertexfragment.com/ramblings/volumetric-cloud-upsampling/){: #VertexFragmentUpsampling}
3. [Interleaved Gradient Noise: A Different Kind of Low Discrepancy Sequence](https://blog.demofox.org/2022/01/01/interleaved-gradient-noise-a-different-kind-of-low-discrepancy-sequence/){: #IGN }
4. [A Survey of Temporal Antialiasing Techniques](http://behindthepixels.io/assets/files/TemporalAA.pdf){: #TAASurvey}
5. [DYNAMIC TEMPORAL ANTIALIASING AND UPSAMPLING in Call of Duty](https://www.activision.com/cdn/research/
Dynamic_Temporal_Antialiasing_and_Upsampling_in_Call_of_Duty_v4.pdf)
6. [Temporal AA and the quest for the Holy Trail](https://www.elopezr.com/temporal-aa-and-the-quest-for-the-holy-trail/)
7. [Temporal Wavelet upscaling ShaderToy](https://www.shadertoy.com/view/3l3XR7){: #TemporalWaveletShaderToy}
8. [Cloudy Shapes temporal upsample ShaderToy](https://www.shadertoy.com/view/ttjcWh)
9. [PlayDeadGames Temporal Reprojection Anti-Aliasing Code](https://github.com/playdeadgames/temporal/tree/master/Assets/Shaders){: #PDGTAA }
10. [Unreal Engine Anti-Aliasing and Upscaling](https://dev.epicgames.com/documentation/en-us/unreal-engine/anti-aliasing-and-upscaling-in-unreal-engine#temporalantialiasingupsampling){: #UnrealEngineTAAU }
11. [Screen Percentage with Temporal Upscale](https://dev.epicgames.com/documentation/en-us/unreal-engine/screen-percentage-with-temporal-upscale-in-unreal-engine?application_version=5.1){: #UnrealEngineTemporalUpscale }
12. [Sébastien Hillaire's Production Ready Sky and Atmosphere Rendering](https://sebh.github.io/publications/egsr2020.pdf){: #sebastien }


[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
