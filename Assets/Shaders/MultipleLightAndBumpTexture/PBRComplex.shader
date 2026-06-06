// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PBR Complex"
{
    
    Properties
    {
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo", 2D) = "white" {}
        
        [NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1
        
        [NoScaleOffset] _MetallicMap("Metallic", 2D) = "white"{}
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        
        _DetailTex ("Detail Albedo", 2D) = "gray" {}
        [NoScaleOffset] _DetailNormalMap ("Detail Normals", 2D) = "bump" {}
		_DetailBumpScale ("Detail Bump Scale", Float) = 1

        [NoScaleOffset] _EmissionMap ("Emission", 2D) = "black"{}
        [HDR] _Emission ("Emission", color) = (0, 0, 0) 

        [NoScaleOffset] _OcclusionMap("Occlusion", 2D) = "black" {}
        _OcclusionStrength ("Occlusion Strength", Range(0, 1)) = 1

        [NoScaleOffset] _DetailMask("Detail Mask", 2D) = "White" {}

    }

    // CGINCLUDE
	// #define BINORMAL_PER_FRAGMENT
	// ENDCG
    CustomEditor "MyLightingShaderGUI"
    SubShader
    {
        Pass
        {
            Tags { 
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _NORMAL_MAP
			#pragma shader_feature _OCCLUSION_MAP
			#pragma shader_feature _EMISSION_MAP
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
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
            #pragma shader_feature _METALLIC_MAP
			#pragma shader_feature _ _SMOOTHNESS_ALBEDO _SMOOTHNESS_METALLIC
			#pragma shader_feature _NORMAL_MAP
			#pragma shader_feature _DETAIL_MASK
			#pragma shader_feature _DETAIL_ALBEDO_MAP
			#pragma shader_feature _DETAIL_NORMAL_MAP
            #pragma multi_compile_fwdadd_fullshadows
            #include "My Lighting.cginc"
            ENDCG
        }
        Pass//处理阴影的Pass
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
