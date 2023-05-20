Shader "ShaderCourse/Lesson11Shader"
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

        _UVTex("UV Texture", 2D) = "white" {}
 
        _U_Params("U Parameters", Vector) = (0,0,0,0)
        _V_Params("V Parameters", Vector) = (0,0,0,0)
    
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

            sampler2D _UVTex;
            float4 _UVTex_ST;

            float4 _U_Params, _V_Params;

                
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


                float2 U_Vector = float2(0.5,0.5) - i.uv1_uv2.xy;
                float U = length(U_Vector);
                U = frac(U * _U_Params.x + _Time.x * _U_Params.y) ;

                float2 V_Remap = i.uv1_uv2 * 2 - 1;
                float V = (atan2(V_Remap.x, V_Remap.y) / (2 * UNITY_PI)) + 0.5; 
                V = frac(V * _V_Params.x + _Time.x * _V_Params.y);

                float2 radialUV = float2(U,V);

                fixed4 mask = tex2D(_MainTex, i.uv1_uv2.xy * 2);
                fixed4 uvTex = tex2D(_UVTex, radialUV);
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy + uvTex.rg * mask.a);


                
                return fixed4(mainTex.rgb,1);

                
                
                //fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy);
                

                fixed3 color = mainTex.rgb;
                fixed alpha = 1;
                return fixed4(color,alpha);
            }
            ENDCG
        }
    }
}



