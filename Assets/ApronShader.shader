﻿Shader "Custom/Diffuse" {
	Properties{
		[HideInInspector] _Control("Control (RGBA)", 2D) = "red" {}
	[HideInInspector] _Splat3("Layer 3 (A)", 2D) = "white" {}
	[HideInInspector] _Splat2("Layer 2 (B)", 2D) = "white" {}
	[HideInInspector] _Splat1("Layer 1 (G)", 2D) = "white" {}
	[HideInInspector] _Splat0("Layer 0 (R)", 2D) = "white" {}
	// used in fallback on old cards & base map
	[HideInInspector] _MainTex("BaseMap (RGB)", 2D) = "white" {}
	[HideInInspector] _Color("Main Color", Color) = (1,1,1,1)
	}

		SubShader{
		Tags{
		"SplatCount" = "4"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
		CGPROGRAM
#pragma target 4.0
#pragma surface surf Lambert
		struct Input {
		float2 uv_Control : TEXCOORD0;
		float2 uv_Splat0 : TEXCOORD1;
		float2 uv_Splat1 : TEXCOORD2;
		float2 uv_Splat2 : TEXCOORD3;
		float2 uv_Splat3 : TEXCOORD4;
	};

	sampler2D _Control;
	sampler2D _Splat0,_Splat1,_Splat2,_Splat3;

	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 splat_control = tex2D(_Control, IN.uv_Control);
		fixed3 col;
		col = splat_control.r * tex2D(_Splat0, IN.uv_Splat0).rgb;
		col += splat_control.g * tex2D(_Splat1, IN.uv_Splat1).rgb;
		col += splat_control.b * tex2D(_Splat2, IN.uv_Splat2).rgb;
		col = splat_control.a > 0 ? tex2D(_Splat3, IN.uv_Splat3).rgb : col; // col * clamp(pow(1 - splat_control.a * 1.1 - splat_control.a * tex2D(_Splat3, IN.uv_Splat3).a, 3.4), 0, 1) + tex2D(_Splat3, IN.uv_Splat3).rgb * clamp(splat_control.a * 3.0 + splat_control.a * tex2D(_Splat3, IN.uv_Splat3).a * 4, 0.0, 1.0);
		
		o.Albedo = col;
		o.Alpha = 0.0;
	}
	ENDCG
	}

		Dependency "AddPassShader" = "Hidden/TerrainEngine/Splatmap/Lightmap-AddPass"
		Dependency "BaseMapShader" = "Diffuse"
		Dependency "Details0" = "Hidden/TerrainEngine/Details/Vertexlit"
		Dependency "Details1" = "Hidden/TerrainEngine/Details/WavingDoublePass"
		Dependency "Details2" = "Hidden/TerrainEngine/Details/BillboardWavingDoublePass"
		Dependency "Tree0" = "Hidden/TerrainEngine/BillboardTree"

		// Fallback to Diffuse
		Fallback "Diffuse"
}
