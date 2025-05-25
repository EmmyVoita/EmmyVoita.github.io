#include "IncColorSpaceOperations.hlsl"

#ifndef __TEMPORALUPSAMPLE_CGINC__
#define __TEMPORALUPSAMPLE_CGINC__

    
    //sequence from http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
    static const float phi2=1.32471795724474602596090885447809734; //root of X^3-X-1=0.

    float bayer2(float2 a){
        a = floor(a);
        return frac( dot(a, float2(.5, a.y * .75)) );
    }

    float bayer4(float a)
    {
        return bayer2( .5 * a) * .25 + bayer2(a);
    }

    float bayer8(float a)
    {
        return bayer4( .5 * a) * .25 + bayer2(a);
    }

    float bayer16(float a)
    {
        return bayer8( .5 * a) * .25 + bayer2(a);
    }

    float dot2(float2 a)
    {
        return dot(a, a);
    }

    float sinc(float x)
    {
        return sin(x) / x;
    }


    float lacnzos(float x,float s){
        float xpi = acos(-1.)*x;
        float xpis = s*xpi;
        return x==0.?1.:sinc(xpi)*sinc(xpis);
    }
    

    float4 TemporalUpSample(sampler2D _currSampler, sampler2D _DepthBuffer, float4 _CurrTexelSize, float4 _InputTexelSize, float4 historySample, float2 uv, float RENDERSCALE, int iFrame, float2 ss_vel)
    {
        
        float2 I2 = RENDERSCALE * (uv * _CurrTexelSize.zw);

        float k = 80.; // Defines the sharpness of the filtering (used for Gaussian-like smoothing)
        int kernell = 1;    // Size of the filter kernel. A kernel size of 1 means a 3x3 neighborhood (one pixel around the center pixel). This can be increased for more smoothing.


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
        float blendFactor = isEdge ? 0.8 : 0.2; // Use a higher blend factor for edges to retain more detail

        O = lerp(O / s, clampedO, blendFactor);
        O = resolve_color(O);
        
        return O;
    }           

#endif