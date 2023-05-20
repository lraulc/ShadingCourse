Shader "Shader3DCourse/Lesson6_3DShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
        _Gloss ("Gloss", float) = 1
        _SpecIntensity ("Spec Intensity", float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
            };

            sampler2D _MainTex, _NormalMap;
            float4 _MainTex_ST;
            float _Gloss, _SpecIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Normal Maps
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.tangent, o.normal);

                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                //Normal Maps
                float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                float3 finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;

                //Texture and Light
                fixed4 col = tex2D(_MainTex, i.uv);
                float ndotl = max(0, dot(finalNormal, _WorldSpaceLightPos0.xyz));
                float3 ligthing = ndotl * _LightColor0 + ShadeSH9(float4(finalNormal,1));

                //Spec
                float3 reflectedLight = reflect(_WorldSpaceLightPos0.xyz, finalNormal);
                float spec = max(0, dot(reflectedLight, -i.viewDir));
                float3 finalSpec = pow(spec, _Gloss) * _SpecIntensity * _LightColor0;

                //Reflection
                float3 reflection = reflect(-i.viewDir, finalNormal);
                float3 reflectionSample = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflection);

                //final color    
                float3 finalColor = col * ligthing * reflectionSample + finalSpec;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}