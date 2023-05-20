Shader "Shader3DCourse/Lesson9_3DShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Toggle] NORMAL_MAP ("Normal Mapping", float) = 0
        _NormalMapOne ("Normal Map One", 2D) = "white" {}
        _NormalMapTwo ("Normal Map Two", 2D) = "white" {}


        _FlowMap ("Flow Map", 2D) = "white" {}

        _WaterFlowSpeed ("Water Flow Speed", float) = 1

        [Toggle] SPEC ("Specular", float) = 0
        _Gloss ("Gloss", float) = 1
        _SpecIntensity ("Spec Intensity", float) = 1

        [Toggle] REFLECTION ("Reflection", float) = 0

        [Toggle] FRESNEL ("Fresnel", float) = 0
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _FresnelRamp ("Fresnel Ramp", Range(0,10)) = 1
        _FresnelIntensity ("Fresnel Intensity", Range(0,10)) = 1
            
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
        
            #pragma shader_feature __ NORMAL_MAP_ON
            #pragma shader_feature __ SPEC_ON
            #pragma shader_feature __ REFLECTION_ON
            #pragma shader_feature __ FRESNEL_ON

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

            sampler2D _MainTex, _NormalMapOne, _NormalMapTwo, _FlowMap;
            float4 _MainTex_ST;
            float _Gloss, _SpecIntensity, _FresnelRamp, _FresnelIntensity, _WaterFlowSpeed;

            float4 _FresnelColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Normal Maps
                o.normal = UnityObjectToWorldNormal(v.normal);
                #if NORMAL_MAP_ON
                    o.tangent = UnityObjectToWorldDir(v.tangent);
                    o.bitangent = cross(o.tangent, o.normal);
                #endif

                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }




            fixed4 frag (v2f i) : SV_Target
            {

                //Normal Maps
                float3 finalNormal = i.normal;

                #if NORMAL_MAP_ON
                    float3 normalMapOne = UnpackNormal(tex2D(_NormalMapOne, i.uv + _Time.xx * _WaterFlowSpeed));
                    float3 finalNormalOne = normalMapOne.r * i.tangent + normalMapOne.g * i.bitangent + normalMapOne.b * i.normal;

                    float3 normalMapTwo = UnpackNormal(tex2D(_NormalMapTwo, i.uv - _Time.xx * _WaterFlowSpeed));
                    float3 finalNormalTwo = normalMapTwo.r * i.tangent + normalMapTwo.g * i.bitangent + normalMapTwo.b * i.normal;

                    finalNormal = normalize( float3(finalNormalOne.rg + finalNormalTwo.rg, finalNormalOne.b * finalNormalTwo.b) );
                #endif

                //Texture and Light
                fixed4 col = tex2D(_MainTex, i.uv);
                float ndotl = max(0, dot(finalNormal, _WorldSpaceLightPos0.xyz));
                float3 ligthing = ndotl * _LightColor0 + ShadeSH9(float4(finalNormal,1));

                //Spec
                float3 finalSpec = 0;

                #if SPEC_ON
                    float3 reflectedLight = reflect(_WorldSpaceLightPos0.xyz, finalNormal);
                    float spec = max(0, dot(reflectedLight, -i.viewDir));
                    finalSpec = pow(spec, _Gloss) * _SpecIntensity * _LightColor0;
                #endif

                //Reflection
                float3 reflectionSample = 1;
                #if REFLECTION_ON
                    float3 reflection = reflect(-i.viewDir, finalNormal);
                    reflectionSample = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflection);
                #endif

                //fresnel
                float3 fresnelColor = 0;
                #if FRESNEL_ON
                    float fresnelAmount = 1 - max(0, dot(finalNormal, i.viewDir));
                    fresnelAmount = pow(fresnelAmount,_FresnelRamp) * _FresnelIntensity;
                    fresnelColor = fresnelAmount * _FresnelColor;
                #endif


                //final color    
                float3 finalColor = col * ligthing * reflectionSample + finalSpec + fresnelColor;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}