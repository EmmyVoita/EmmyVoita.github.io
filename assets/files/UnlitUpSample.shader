Shader "Custom/UnlitUpSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PrevFrameColor ("Texture", 2D) = "white" {}
        _DepthBuffer ("Texture", 2D) = "white" {}
        _MotionVectors ("Texture", 2D) = "white" {}
    }

    CGINCLUDE

    #include "Assets/Resources/CombineAtmoCloud/Includes_V1_1/TemporalReprojection/IncColorSpaceOperations.hlsl"
    #include "Assets/Resources/CombineAtmoCloud/Includes_V1_1/TemporalReprojection/IncTemporalUpsampling.hlsl"
    #include "Assets/Resources/CombineAtmoCloud/Includes_V1_1/TemporalReprojection/TemporalReprojection.hlsl"

    #pragma multi_compile __ USE_YCOCG
    #pragma multi_compile __ DENOISE_COLORSAMPLES
    #pragma multi_compile __ USE_TEMPORAL_UPSAMPLING


    float2 _FrameJitter;
    float _RenderScale;
    float _iFrame;

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            

            float2 _Resolution;
            float2 _InputResolution;
            

            float4 _MainTex_ST;

            sampler2D _MainTex;
            
            SamplerState _MainTexSampler
            {
                Filter = MinMagPointMipNone;
                AddressU = Clamp;
                AddressV = Clamp;
            };


            sampler2D _PrevFrameColor;

            SamplerState _PrevFrameColorSampler
            {
                Filter = MinMagPointMipNone;
                AddressU = Clamp;
                AddressV = Clamp;
            };

            sampler2D _MotionVectors; 

            SamplerState _MotionVectorsSampler
            {
                Filter = MinMagMipLinear;
                AddressU = Clamp;
                AddressV = Clamp;
            };

            sampler2D _DepthBuffer;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float2 ss_vel;
                float vs_dist;

                float4 texelSize = float4(1.0 / _Resolution.x, 1.0 / _Resolution.y, _Resolution.x, _Resolution.y);
                float4 inputTexelSize = float4(1.0 / _InputResolution.x, 1.0 / _InputResolution.y, _InputResolution.x, _InputResolution.y);

                // Grab ss_vel
                ComputeTemporalReprojectionIn(_MotionVectors, _DepthBuffer, texelSize, _ZBufferParams, i.uv, _FrameJitter, ss_vel, vs_dist);

                float4 texel1 = sample_color(_PrevFrameColor, i.uv - ss_vel);

                #if USE_TEMPORAL_UPSAMPLING
                    float4 out_color = TemporalUpSample(_MainTex, _DepthBuffer, texelSize, inputTexelSize, texel1, i.uv, _RenderScale, _iFrame);
                #else
                    float4 out_color = tex2D(_MainTex, i.uv);
                #endif

                return out_color;
            }
            ENDCG
        }
    }
}