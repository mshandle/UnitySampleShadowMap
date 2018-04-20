// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "sampleShadowMap/receiveShadowDiffuse"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
    }

	SubShader
	{
		Tags
		{
		 	"RenderType"="Opaque" 
	 	}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv:TEXCOORD0;
				float4 worldPos: TEXCOORD1;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LightDepthTex;
			float4x4 _LightProjection;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
				o.worldPos = fixed4(worldPos.xyz,1.0);
				return o;
			}

			

			fixed4 frag(v2f i) : SV_Target
			{
				// convert to light camera space
				fixed4 lightClipPos = mul(_LightProjection , i.worldPos);
				//NDC[-1,1]
			    lightClipPos.xyz = lightClipPos.xyz / lightClipPos.w ;
				//UV[0,1]
				float3 pos = lightClipPos * 0.5 + 0.5 ;
				//sample
				fixed4 depthRGBA = tex2D(_LightDepthTex,pos.xy);

				float depth = DecodeFloatRGBA(depthRGBA);
				//compare depth value,0.01 basi
				float color = (1.0 - step(lightClipPos.z + 0.01 , depth)) * 0.5f;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				return fixed4(col.x - color, col.y - color, col.z - color, col.w);
		
				
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
