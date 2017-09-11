// AOE meaning Area Of Effect
Shader "Custom/matAOE" {
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,1)
		[HDR]_BackColor("Color", Color) = (1,1,1,1) //
		_FresnelPower("Fresnel Power", Range(0.2, 3)) = 1.0
		_InvertFade("Soft edge factor", Range(0.01, 10)) = 1.0
	}
		SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent+10" }
		LOD 200

		Cull front

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
		#pragma target 3.0

		struct Input
	{
		float3 viewDir;
		float4 screenPos;
		float eyeDepth;
	};

	sampler2D_float _CameraDepthTexture;
	float4 _CameraDepthTexture_TexelSize;
	float _InvertFade;
	float _FresnelPower;
	fixed4 _Color;
	fixed4 _BackColor;

	void vert(inout appdata_full v, out Input o)
	{
		UNITY_INITIALIZE_OUTPUT(Input, o);
		COMPUTE_EYEDEPTH(o.eyeDepth);
	}

	void surf(Input IN, inout SurfaceOutputStandard o)
	{
		float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,
			UNITY_PROJ_COORD(IN.screenPos));
		float sceneZ = LinearEyeDepth(rawZ);
		float camDist = IN.eyeDepth;
		float fade = 1.0 - saturate(_InvertFade*(sceneZ - camDist));

		o.Emission = _BackColor;
		o.Alpha = fade;
	}
	ENDCG

		Cull back

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
		#pragma target 3.0

		struct Input
	{
		float3 viewDir;
		float4 screenPos;
		float eyeDepth;
	};

	sampler2D_float _CameraDepthTexture;
	float4 _CameraDepthTexture_TexelSize;
	float _InvertFade;
	float _FresnelPower;
	fixed4 _Color;
	fixed4 _BackColor;

	void vert(inout appdata_full v, out Input o)
	{
		UNITY_INITIALIZE_OUTPUT(Input, o);
		COMPUTE_EYEDEPTH(o.eyeDepth);
	}

	void surf(Input IN, inout SurfaceOutputStandard o)
	{
		float NdotV = dot(o.Normal, normalize(IN.viewDir.xyz));
		float fresnel = 1.0 - abs(NdotV);
		fresnel = pow(fresnel, _FresnelPower);

		float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,
			UNITY_PROJ_COORD(IN.screenPos));
		float sceneZ = LinearEyeDepth(rawZ);
		float camDist = IN.eyeDepth;
		float fade = 1.0 - saturate(_InvertFade*(sceneZ - camDist));

		o.Emission = _Color;
		o.Alpha = max(fresnel, fade);
	}
	ENDCG
	}
		FallBack "Diffuse"
}
