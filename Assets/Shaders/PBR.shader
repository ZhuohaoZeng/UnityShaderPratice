// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PBRBase"
{
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" {}
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5

    }
    SubShader
    {
        Pass
        {
            Tags { 
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma multi_compile _ VERTEXLIGHT_ON
            #define FORWARD_BASE_PASS
            #include "My Lighting.cginc"
            ENDCG
        }
        Pass
        {
            Tags { 
                "LightMode" = "ForwardAdd"
            }
            Blend One One
            ZWrite Off
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #include "My Lighting.cginc"
            ENDCG
        }
    }
}
