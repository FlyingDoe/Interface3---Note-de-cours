Shader "Custom/mat_ToonShader" {
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_OutlineThickness("Outline thickness", Range(0, 1)) = 0.5
		[HDR]_OutlineColor("Outline Color", Color) = (1,0,0,1)
		[KeywordEnum(ConstantThickness, VariableThickness)] _Style("Style", Float) =0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200
			Cull back

			CGPROGRAM

			#pragma surface surf Standard fullforwardshadows
			#pragma target 3.0

			sampler2D _MainTex;

			struct Input
			{
				float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
			ENDCG

			Cull Front

			CGPROGRAM

			#pragma multi_compile _STYLE_CONSTANTTHICKNESS _STYLE_VARIABLETHICKNESS
			#pragma surface surf Lambert fullforwardshadows vertex:vert noambient
			#pragma target 3.0

			float _OutlineThickness;
			float4 _OutlineColor;

			struct Input
			{
				float worldPos;
			};

			void vert(inout appdata_full v)
			{
				#if _STYLE_VARIABLETHICKNESS
					v.vertex.xyz += v.normal.xyz * _OutlineThickness * 0.1f;
				#else
					float3 wpos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1));
					float dist = length(wpos - _WorldSpaceCameraPos);
					v.vertex.xyz += v.normal.xyz * _OutlineThickness * dist * 0.025f;
				#endif
			}

			void surf (Input IN, inout SurfaceOutput o) // SurfaceOutput pcq on utilise Lambert dans les pragma
			{
				o.Emission = _OutlineColor;
			}

			ENDCG
			
		}
			FallBack "Diffuse"
}
