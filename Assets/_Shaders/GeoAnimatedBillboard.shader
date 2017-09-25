Shader "Custom/Geometry/AnimatedBillboard"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
		_Size ("Size", Range(0, 0.2)) = 0.05
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
		_Value1 ("Value 1", Range(0,1)) = 0
		_Value2 ("Value 2", Range(0,10)) = 0
		_Value3 ("Value 3", Range(0,5)) = 0
		_ValueFactor ("Value Factor", Range(0,1)) = 0
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
			float _Size;
			float _Cutoff;
			float _Value1;
			float _Value2;
			float _Value3;
			float _ValueFactor;

			struct v2g
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 vertex : TEXCOORD1;
				float3 normal : NORMAL;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float light : TEXCOORD1;
				float3 normal : NORMAL;
			};

			v2g vert(appdata_full v)
			{
				v2g o = (v2g)0;
				o.vertex = v.vertex;
				o.pos = UnityObjectToClipPos(v.vertex);
				_Value1 *= _ValueFactor;
				_Value2 *= _ValueFactor;
				_Value3 *= _ValueFactor;

				// vertex animation
				o.vertex.x += sin( ( o.vertex.y + _Time.y * _Value3 ) * _Value2 ) * _Value1;

				o.normal = v.normal;
				o.uv = float2(0, 0);
				return o;
			}

			[maxvertexcount(4)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
			{
				g2f o;
				UNITY_INITIALIZE_OUTPUT(g2f, o)
				float3 posi = IN[0].vertex;
				float3 up = UNITY_MATRIX_IT_MV[1].xyz; // camera up vector
				float3 look = UNITY_MATRIX_IT_MV[2].xyz;
				look = normalize(look);
				float3 right = cross(up, look);
				float halfS = 0.5f * _Size;

				float4 v[4];
				v[0] = float4(posi + halfS * right - halfS * up, 1.0f);
				v[1] = float4(posi + halfS * right + halfS * up, 1.0f);
				v[2] = float4(posi - halfS * right - halfS * up, 1.0f);
				v[3] = float4(posi - halfS * right + halfS * up, 1.0f);

				o.pos = UnityObjectToClipPos(v[0]);
				o.uv = float2(1.0f, 0.0f);
				triStream.Append(o);
				o.uv = float2(1.0f, 1.0f);
				o.pos = UnityObjectToClipPos(v[1]);
				triStream.Append(o);
				o.pos = UnityObjectToClipPos(v[2]);
				o.uv = float2(0.0f, 0.0f);
				triStream.Append(o);
				o.pos = UnityObjectToClipPos(v[3]);
				o.uv = float2(0.0f, 1.0f);
				triStream.Append(o);
			}

			half4 frag(g2f i) : COLOR
			{
				float4 col = tex2D(_MainTex, i.uv);

				if (col.a < _Cutoff)
					discard;

				return col;
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}
