Shader "ShaderCourse/Lesson8Shader"
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
        _UVTex("UV Texture", 2D) = "white" {}

    

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

            sampler2D _UVTex;
            float4 _UVTex_ST;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1_uv2.zw = TRANSFORM_TEX(v.uv, _UVTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Sample Main Tex (Grass)
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy);

                //Sample UV Texture
                fixed4 uvTex = tex2D(_UVTex, i.uv1_uv2.zw);
                float2 mainTexUV = uvTex.rg;
                mainTexUV += float2(0, _Time.x * 10); //Apply uv animation

                
                fixed4 secondaryTex = tex2D(_SecondaryTex, mainTexUV);
                
                fixed3 color = mainTex.rgb * (1 - uvTex.a) + secondaryTex.rgb * uvTex.a;
                fixed alpha = 1;//mainTex.a * uvTex.a; 
                return fixed4(color,alpha);
            }
            ENDCG
        }
    }
}

