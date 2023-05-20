Shader "ShaderCourse/Lesson14Shader"
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

        _Rotation("Rotation", Range(0,6.3)) = 0
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;

            float _Rotation;

            float2 RotatedUV(float2 uv)
            {
                float2 rotateduv = uv;
                rotateduv -= 0.5;
                float c = cos(_Rotation);
                float s = sin(_Rotation);

                float2x2 rotationMatrix = float2x2(c, -s, s, c);
                rotateduv = mul(rotationMatrix, rotateduv);
                rotateduv += 0.5;
                return rotateduv;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1_uv2.zw = RotatedUV(v.uv);
                o.uv1_uv2.zw = TRANSFORM_TEX(o.uv1_uv2.zw, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.zw);           
                fixed3 color = mainTex.rgb;
                fixed alpha = mainTex.a;
                return fixed4(mainTex.rgb,1);
            }
            ENDCG
        }
    }
}