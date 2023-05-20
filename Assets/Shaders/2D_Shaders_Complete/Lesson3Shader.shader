Shader "ShaderCourse/Lesson3Shader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Tint Color", COLOR) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

        // BlendOp Sub
        // Blend Formula
        // FinalValue = SrcFactor * SrcValue +(OPP) DstFactor * DstValue
        // FinalValue = One * SrcValue +(OPP) One * DstValue
        // FinalValue = 1 * SrcValue +(OPP) 1 * DstValue
        // SrcValue * 70% + 30% * DstValue
        
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
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.uv,0,1);
                fixed4 tex = tex2D(_MainTex, i.uv);
                return tex * _Color;
            }
            ENDCG
        }
    }
}
