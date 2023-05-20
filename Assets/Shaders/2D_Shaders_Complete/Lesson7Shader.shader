Shader "ShaderCourse/Lesson7Shader"
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
        _Cutoff("Cutoff", Range(0.0,1.0)) = 0
        _Feather("Feather", Range(0.0,0.1)) = 0

        _EmberColor("Ember Color", Color) = (1,1,1,1)
        _EmberBoost ("Ember Boost", Float) = 0
        _CharColor("Char Color", Color) = (1,1,1,1)

        

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

            float _Cutoff, _Feather, _EmberBoost;
        
            float4 _EmberColor, _CharColor;
            
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
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy);
                fixed4 secondaryTex = tex2D(_SecondaryTex, i.uv1_uv2.zw);
                fixed3 emberArea = step(secondaryTex.r - _Feather,_Cutoff);
                fixed3 burntArea = smoothstep(secondaryTex.r - _Feather, secondaryTex.r + _Feather, _Cutoff);    
                fixed3 emberColor = lerp(mainTex, _EmberColor * _EmberBoost, emberArea);
                fixed3 color = lerp(emberColor, _CharColor, burntArea);
                //float _AnimatedCutoff = 0.5 * sin(_Time.x * 40) + 0.5;
                fixed alpha = saturate(mainTex.a - step(secondaryTex.r + _Feather,_Cutoff));//smoothstep(secondaryTex.r - _Feather, secondaryTex.r + _Feather, _Cutoff);
                return fixed4(color,alpha);
            }
            ENDCG
        }
    }
}

