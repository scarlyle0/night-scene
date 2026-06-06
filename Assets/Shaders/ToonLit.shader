Shader "Custom/ToonLit"
{
    Properties
    {
        _ShadowColor ("Shadow Color", Color) = (0.05, 0.07, 0.15, 1)
        _LitColor ("Lit Color Tint", Color) = (0.8, 0.85, 1.0, 1)
        _ShadowThreshold ("Shadow Threshold", Range(-1, 1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 vertexColor : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float4 vertexColor : COLOR;
                float3 positionWS  : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _ShadowColor;
                float4 _LitColor;
                float  _ShadowThreshold;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                OUT.vertexColor = IN.vertexColor;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 normal   = normalize(IN.normalWS);

                // Hard stepped diffuse
                float NdotL = dot(normal, lightDir);
                float step  = NdotL > _ShadowThreshold ? 1.0 : 0.0;

                // Blend vertex color with lit/shadow tint
                float3 litResult    = IN.vertexColor.rgb * _LitColor.rgb;
                float3 shadowResult = IN.vertexColor.rgb * _ShadowColor.rgb;
                float3 finalColor   = lerp(shadowResult, litResult, step);

                return half4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}