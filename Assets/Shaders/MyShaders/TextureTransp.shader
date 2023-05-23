Shader "MYShaders/TextureTransparency"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Color ("Tint Color", COLOR) = (1,1,1,1)
        
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", float) = 5

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", float) = 10

        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("Blend Operation", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        /*
        Blend Forumula
        FinalValue = SrcFactor * Srcvalue +(OPP) DstFactor * DstValue
        FinalValue = 1 * SrcValue +(OPP) 1 * DstValue

        Result: SrcValue * [_SrcFactor] [_BlendOPP] 1 * [DstFactor]
        */

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_BlendOp]



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
                // sample the texture
                fixed4 col = fixed4(i.uv,0,1);
                fixed4 tex = tex2D(_MainTex, i.uv);
                return tex * fixed4(1,1,1,0.5);
            }
            ENDCG
        }
    }
}
