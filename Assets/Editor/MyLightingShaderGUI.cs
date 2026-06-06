using UnityEngine;
using UnityEditor;
using System;
using Palmmedia.ReportGenerator.Core.Reporting.Builders.Rendering;
using UnityEditor.Experimental;

enum SmoothnessSource {
    Uniform, Albedo, Metallic
}

public class MyLightingShaderGUI : ShaderGUI
{
    Material target;
    MaterialEditor editor;
    MaterialProperty[] properties;
    public override void OnGUI(
        MaterialEditor editor, MaterialProperty[] properties)
    {
        this.target = editor.target as Material;
        this.editor = editor;
        this.properties = properties;
        DoMain();
        DoSecondary();
    }

    void DoMain()
    {
        GUILayout.Label("Main Maps", EditorStyles.boldLabel);
        MaterialProperty mainTex = FindProperty("_MainTex");
        MaterialProperty tint = FindProperty("_Tint");
        editor.TexturePropertySingleLine(
            MakeLabel(mainTex.displayName, "Albedo (RGB)"), mainTex, tint);
        DoMetallic();
        DoSmoothness();
        DoNormals();
        DoOcclusion();
        DoEmission();
        DoDetailMask();
        editor.TextureScaleOffsetProperty(mainTex);

    }
    void DoMetallic()
    {
        MaterialProperty map = FindProperty("_MetallicMap");
		editor.TexturePropertySingleLine(MakeLabel(map, "Metallic (R)"), map, 
        map.textureValue ? null : FindProperty("_Metallic"));
        SetKeyword("_METALLIC_MAP", map.textureValue);
    }
    void DoSmoothness()
    {
        SmoothnessSource source = SmoothnessSource.Uniform;
        if(IsKeyWordEnabled("_SMOOTHNESS_ALBEDO"))
        {
            source = SmoothnessSource.Albedo;
        }
        else
        {
            source = SmoothnessSource.Metallic;
        }
        MaterialProperty slider = FindProperty("_Smoothness");
        EditorGUI.indentLevel += 2;
        editor.ShaderProperty(slider, MakeLabel(slider));
        EditorGUI.indentLevel += 1;
        EditorGUI.BeginChangeCheck();
        source = (SmoothnessSource) EditorGUILayout.EnumPopup(MakeLabel("Source"), source);
        if(EditorGUI.EndChangeCheck())
        {
            RecordAction("Smoothness Source");
            SetKeyword("_SMOOTHNESS_ALBEDO", source == SmoothnessSource.Albedo);
			SetKeyword("_SMOOTHNESS_METALLIC", source == SmoothnessSource.Metallic);
        }
        EditorGUI.indentLevel -= 3;

    }

    void DoNormals()
    {
        MaterialProperty map = FindProperty("_NormalMap");
        Texture tex = map.textureValue;
        EditorGUI.BeginChangeCheck();
		editor.TexturePropertySingleLine(MakeLabel(map), map, 
        tex ? FindProperty("_BumpScale") : null);
        if(EditorGUI.EndChangeCheck() && tex != map.textureValue)
        {
            SetKeyword("_NORMAL_MAP", map.textureValue);
        }
    }

    void DoEmission()
    {
        MaterialProperty map = FindProperty("_EmissionMap");
        EditorGUI.BeginChangeCheck();
		editor.TexturePropertyWithHDRColor( 
			MakeLabel("Emission (RGB)"), map, FindProperty("_Emission"), false
		);
        if (EditorGUI.EndChangeCheck()) {
			SetKeyword("_EMISSION_MAP", map.textureValue);
		}
    }

    void DoOcclusion()
    {
        MaterialProperty map = FindProperty("_OcclusionMap");
        EditorGUI.BeginChangeCheck();
        editor.TexturePropertySingleLine(MakeLabel(map, "Occlusion (G)"), map,
        map.textureValue ? FindProperty("_OcclusionStrength") : null);

        if (EditorGUI.EndChangeCheck())
        {
            SetKeyword("_OCCLUSION_MAP", map.textureValue);
        }
    }
    
    void DoDetailMask()
    {
        MaterialProperty mask = FindProperty("_DetailMask");
		EditorGUI.BeginChangeCheck();
		editor.TexturePropertySingleLine(
			MakeLabel(mask, "Detail Mask (A)"), mask
		);
		if (EditorGUI.EndChangeCheck()) {
			SetKeyword("_DETAIL_MASK", mask.textureValue);
		}
    }

    void DoSecondary () {
		GUILayout.Label("Secondary Maps", EditorStyles.boldLabel);
        EditorGUI.BeginChangeCheck();
		MaterialProperty detailTex = FindProperty("_DetailTex");
		editor.TexturePropertySingleLine(
			MakeLabel(detailTex, "Albedo (RGB) multiplied by 2"), detailTex
		);
        if (EditorGUI.EndChangeCheck()) {
			SetKeyword("_DETAIL_ALBEDO_MAP", detailTex.textureValue);
		}
        DoSecondaryNormals();
		editor.TextureScaleOffsetProperty(detailTex);
	}

    private void DoSecondaryNormals()
    {
        MaterialProperty map = FindProperty("_DetailNormalMap");
        EditorGUI.BeginChangeCheck();
		editor.TexturePropertySingleLine(
			MakeLabel(map), map,
			map.textureValue ? FindProperty("_DetailBumpScale") : null
		);
        if (EditorGUI.EndChangeCheck()) {
			SetKeyword("_DETAIL_NORMAL_MAP", map.textureValue);
		}
    }
    MaterialProperty FindProperty(string name)
    {
        return FindProperty(name, properties);
    }

    static GUIContent staticLabel = new GUIContent();
    static GUIContent MakeLabel (string text, string tooltip = null)
    {
        staticLabel.text = text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    static GUIContent MakeLabel(MaterialProperty property, string tooltip = null)
    {
        staticLabel.text = property.displayName;
		staticLabel.tooltip = tooltip;
		return staticLabel;
    }

    void SetKeyword(string keyword, bool state)
    {
        if (state)
        {
            foreach (Material m in editor.targets)
            {
                m.EnableKeyword(keyword);
            }
        }
        else
        {
            foreach (Material m in editor.targets)
            {
                m.DisableKeyword(keyword);
            }
        }
    }

    bool IsKeyWordEnabled(string keyword)
    {
        return target.IsKeywordEnabled(keyword);
    }

    void RecordAction (string label)
    {
        editor.RegisterPropertyChangeUndo(label);
    }
}