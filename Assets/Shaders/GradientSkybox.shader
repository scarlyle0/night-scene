Shader "Custom/GradientSkybox"
{
    Properties
    {
        _TopColor ("Top Color", Color) = (0.02, 0.03, 0.08, 1)
        _HorizonColor ("Horizon Color", Color) = (0.05, 0.06, 0.12, 1)
        _BottomColor ("Bottom Color", Color) = (0.01, 0.01, 0.03, 1)
        _HorizonHeight ("Horizon Height", Range(-1, 1)) = 0.0
        _Exponent ("Gradient Power", Range(0.1, 5)) = 1.5

        _StarColor ("Star Color", Color) = (1, 1, 1, 1)
        _StarDensity ("Star Density", Range(0, 1)) = 0.08
        _StarBrightness ("Star Brightness", Range(0, 5)) = 1.2
        _StarSize ("Star Sharpness", Range(1, 200)) = 45
        _TwinkleSpeed ("Twinkle Speed", Range(0, 10)) = 1.5
        _TwinkleAmount ("Twinkle Amount", Range(0, 1)) = 0.6
    }
    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Background" }
        Cull Off ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionOS : TEXCOORD0;
            };

            float4 _TopColor;
            float4 _HorizonColor;
            float4 _BottomColor;
            float _HorizonHeight;
            float _Exponent;

            float4 _StarColor;
            float _StarDensity;
            float _StarBrightness;
            float _StarSize;
            float _TwinkleSpeed;
            float _TwinkleAmount;

            // Hash function — turns a cell into a pseudo-random value
            float hash(float3 p)
            {
                p = frac(p * float3(443.897, 441.423, 437.195));
                p += dot(p, p.yzx + 19.19);
                return frac((p.x + p.y) * p.z);
            }

            // 3D cell noise — divides sky into cells, one potential star per cell
            float stars(float3 dir)
            {
                // Scale up so we get many cells across the sky
                float3 scaled = dir * 200.0;
                float3 cell = floor(scaled);
                float3 local = frac(scaled);

                float starValue = 0.0;

                // Does this cell contain a star? (use a dedicated hash so it's
                // independent of the values used for position/twinkle/brightness)
                float present = hash(cell + 9.0);

                if (present < _StarDensity)
                {
                    // Random position within the cell
                    float3 starPos = float3(
                        hash(cell + 1.0),
                        hash(cell + 2.0),
                        hash(cell + 3.0)
                    );

                    float dist = length(local - starPos);
                    float brightness = saturate(1.0 - dist * _StarSize);

                    // Per-star phase — unique random offset spread across full cycle
                    float phase = hash(cell + 13.0) * 6.2831853; // 0 to 2*pi
                    // Per-star speed — each star twinkles at its own rate (0.5x-1.5x)
                    float starSpeed = _TwinkleSpeed * (0.5 + hash(cell + 17.0));

                    float tw = 1.0 - _TwinkleAmount +
                        _TwinkleAmount * (0.5 + 0.5 * sin(_Time.y * starSpeed + phase));

                    // Vary base brightness per star so some are dim, some bright
                    float starMag = 0.4 + 0.6 * hash(cell + 5.0);

                    starValue = brightness * tw * starMag;
                }

                return starValue;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionOS = IN.positionOS.xyz;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 dir = normalize(IN.positionOS);

                // --- Gradient ---
                float h = dir.y - _HorizonHeight;
                float3 col;
                if (h > 0)
                {
                    float t = pow(saturate(h), _Exponent);
                    col = lerp(_HorizonColor.rgb, _TopColor.rgb, t);
                }
                else
                {
                    float t = pow(saturate(-h), _Exponent);
                    col = lerp(_HorizonColor.rgb, _BottomColor.rgb, t);
                }

                // --- Stars (full 360, no horizon fade) ---
                float starField = stars(dir);
                col += _StarColor.rgb * starField * _StarBrightness;

                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
