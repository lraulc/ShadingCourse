Shader "ShaderCourse/Lesson13Shader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0

        _SecondaryTex("Secondary Texture", 2D) = "white" {}

        _MidPoint("MidPoint", Range(0,1)) = 0.5

        _Thickness("Thickness", Range(0,0.2)) = 0.1

        _ShineTint("Shine Tint", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]
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
                float4 vertex : SV_POSITION;
                float4 uv1_uv2 : TEXCOORD0;
                float4 screenSpaceCoords : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;
            float _MidPoint, _Thickness;
            float4 _ShineTint;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1_uv2.zw = TRANSFORM_TEX(v.uv, _SecondaryTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.zw);

                float animatedMidPoint = frac(_Time.x * 10);
                float shine = step(mainTex.a, animatedMidPoint + _Thickness) - step(mainTex.a, animatedMidPoint - _Thickness);
                
                fixed3 color = mainTex.rgb + shine;
                fixed alpha = mainTex.a;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}