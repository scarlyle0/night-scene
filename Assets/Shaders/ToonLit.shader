Shader "Custom/ToonLit"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Shadow Color", Color) = (0.05, 0.07, 0.15, 1)
        _LitColor ("Lit Color Tint", Color) = (0.8, 0.85, 1.0, 1)
        _ShadowThreshold ("Shadow Threshold", Range(-1, 1)) = 0.0
        _UseVertexColor ("Use Vertex Color", Range(0, 1)) = 0
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
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _ShadowColor;
                float4 _LitColor;
                float  _ShadowThreshold;
                float  _UseVertexColor;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                OUT.vertexColor = IN.vertexColor;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 normal   = normalize(IN.normalWS);
            
                float NdotL = dot(normal, lightDir);
            
                // Three-tone stepping
                float lit;
                if (NdotL > 0.3)       lit = 1.0;   // fully lit
                else if (NdotL > -0.1) lit = 0.5;   // midtone
                else                   lit = 0.0;   // shadow
            
                float3 baseColor = lerp(_BaseColor.rgb, IN.vertexColor.rgb, _UseVertexColor);
            
                float3 midColor = (_LitColor.rgb + _ShadowColor.rgb) * 0.5;
                float3 finalTint = lerp(_ShadowColor.rgb, _LitColor.rgb, lit);
            
                float3 finalColor = baseColor * finalTint;
            
                return half4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}