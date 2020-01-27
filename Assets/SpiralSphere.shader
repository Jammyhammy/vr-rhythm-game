// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SpiralSphere" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ProjectionDirection ("Projection Direction",  Range(0, 10)) = 1
	}
	SubShader {
		Cull Back
		Tags { "RenderType"="Transparent" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard nodirlightmap noshadow  

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		float4 _MainTex_ST;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float4 screenPos;
			float3 viewDir;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _ProjectionDirection;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		//UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		//UNITY_INSTANCING_BUFFER_END(Props)

		float t;
		float spiral(float2 m) {
			float r = length(m);
			float a = atan2(m.x, m.y);
			float v = sin(400.*(sqrt(r)-0.02*a-.03*t));
			return clamp(v,0.,1.);

		}       	
		float2 GetScreenUV(float2 clipPos, float UVscaleFactor)
		{
			float4 SSobjectPosition = UnityObjectToClipPos (float4(0,0,0,1.0)) ;
			float2 screenUV = float2(clipPos.x,clipPos.y);
			float screenRatio = _ScreenParams.y/_ScreenParams.x;
	
			screenUV.x -= SSobjectPosition.x/(SSobjectPosition.w);
			screenUV.y -= SSobjectPosition.y/(SSobjectPosition.w);
	
			screenUV.y *= screenRatio;
	
			screenUV *= 1/UVscaleFactor;
			screenUV *= SSobjectPosition.z;
	
			return screenUV;
		}

		inline void ObjSpaceUVOffset(inout float2 screenUV, in float screenRatio)
		{
			float4 objPos = float4(UNITY_MATRIX_MVP[0].w, UNITY_MATRIX_MVP[1].w, UNITY_MATRIX_MVP[2].w, UNITY_MATRIX_MVP[3].w);
			
			float offsetFactorX = 0.5;
			float offsetFactorY = offsetFactorX * screenRatio;
			offsetFactorX *= _MainTex_ST.x;
			offsetFactorY *= _MainTex_ST.y;
			
			//don't scale with orthographic camera
			if (unity_OrthoParams.w < 1)
			{
				//adjust uv scale
				screenUV -= float2(offsetFactorX, offsetFactorY);
				screenUV *= objPos.z;	//scale with cam distance
				screenUV += float2(offsetFactorX, offsetFactorY);
			}
			
			screenUV.x -= objPos.x * offsetFactorX;
			screenUV.y -= objPos.y * offsetFactorY;
		}


		void surf (Input i, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
                t = _Time.y;
			float2 uv0 = i.viewDir.xy / _ScreenParams.xy;
		
			float2 screenUV = uv0; // * _ScreenParams;				
				// float2 screenUV = (float2(i.screenPos.x + -50.0, i.screenPos.y + -50.0) / i.screenPos.w);// * _ScreenParams.zw;
				//float2 screenPixel = screenUV ;
				//setting up direction with a rotation matrix
				// float sinXR = sin(_ProjectionDirection);
				// float cosXR = cos(_ProjectionDirection);
				// float sinYR = sin(_ProjectionDirection);
				// float2x2 rotMatrix = float2x2(cosXR, -sinXR, sinYR, cosXR);
				// float2 rotmatDirection = mul(normalize(float2(1, 1)), rotMatrix);		
				// fixed2 newUV = fixed2(screenPixel.x / _ScreenParams.x * (rotmatDirection.x), (screenPixel.y / _ScreenParams.y * (rotmatDirection.y)));		
                //float2 uv = (GetScreenUV(i.worldPos.xy, 1.)) / 1.;
				//float screenRatio = _ScreenParams.y / _ScreenParams.x;
				//screenUV.y *= screenRatio;
				//ObjSpaceUVOffset(screenUV, screenRatio);
				float2 uv = screenUV;
                
                float2 m = float2(.000005,.000005);

                float v = spiral(uv);

                float3 col = float3(v, v, v);
                
                float4 f = float4(col.x, col.y, col.z,1.);
				o.Albedo = (col.x, col.y, col.z) * 3.;
				// Metallic and smoothness come from slider variables
				o.Alpha = .2;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
