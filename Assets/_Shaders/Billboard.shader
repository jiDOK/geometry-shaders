Shader "Cg  shader for billboards" {
   Properties {
      _MainTex ("Texture Image", 2D) = "white" {}
      _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
      _ScaleX ("Scale X", Float) = 1.0
      _ScaleY ("Scale Y", Float) = 1.0
   }
   SubShader {
      Tags {"Queue" = "Transparent"}
      Pass {   
         Cull Off
         ZWrite Off
         Blend SrcAlpha One
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag

         // User-specified uniforms            
         uniform sampler2D _MainTex;        
         uniform float _ScaleX;
         uniform float _ScaleY;
         uniform float4 _Color;

         struct vertexInput {
            float4 vertex : POSITION;
            float4 tex : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;

            output.pos = mul(UNITY_MATRIX_P, 
              mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
              + float4(input.vertex.x, input.vertex.y, 0.0, 0.0)
              * float4(_ScaleX, _ScaleY, 1.0, 1.0));
 
            output.tex = input.tex;

            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float4 maintex = tex2D(_MainTex, float2(input.tex.xy));
            return maintex * _Color;
         }
 
         ENDCG
      }
   }
}
