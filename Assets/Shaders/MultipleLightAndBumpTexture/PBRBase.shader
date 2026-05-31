// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PBRBase"
{
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" {}
        [NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _DetailTex ("Detail Texture", 2D) = "gray" {}
        [NoScaleOffset] _DetailNormalMap ("Detail Normals", 2D) = "bump" {}
		_DetailBumpScale ("Detail Bump Scale", Float) = 1

    }

    // CGINCLUDE
	// #define BINORMAL_PER_FRAGMENT
	// ENDCG
    
    SubShader
    {
        Pass
        {
            Tags { 
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma multi_compile_fwdbase
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
            #pragma multi_compile_fwdadd_fullshadows
            #include "My Lighting.cginc"
            ENDCG
        }
        Pass
        {
            Tags{
                "LightMode" = "ShadowCaster"
            }
            CGPROGRAM

			#pragma target 3.0
            
			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram
            #pragma multi_compile_shadowcaster
            
			#include "My Shadows.cginc"

			ENDCG
        }
    }
}
