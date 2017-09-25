Shader "Custom/Geometry/FlatDissolve"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_Factor("Dissolve", Range(0,1)) = 0.5
	}
	
	SubShader
	{

		Tags{ "Queue"="Geometry" "RenderType"= "Opaque" "LightMode" = "ForwardBase" }

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float _Factor;

			struct v2g
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 vertex : TEXCOORD1;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float light : TEXCOORD1;
			};

			v2g vert(appdata_full v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				g2f o;

				// compute the normal
				float3 vecA = IN[1].vertex - IN[0].vertex;
				float3 vecB = IN[2].vertex - IN[0].vertex;
				float3 middle = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3.0;
				float3 normal = cross(vecA, vecB);
				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				// compute diffuse light
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				//o.light = max(0.3, dot(normal, lightDir));// darker version
				o.light = (dot(normal, lightDir)+1.8)/2.0;// lighter version

				// compute barycentric uv
				o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

				for(int i = 0; i < 3; i++)
				{
					// lerp between the vert position and the middle of the triangle
					o.pos = UnityObjectToClipPos(lerp(middle, IN[i].vertex, _Factor));
					triStream.Append(o);
				}
			}

			half4 frag(g2f i) : COLOR
			{
				float4 col = tex2D(_MainTex, i.uv);
				col.rgb *= i.light * _Color;
				return col;
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}
