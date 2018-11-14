Shader "Null's Shader/FadeScreen" {
	Properties {
		_Color ("Color", Color) = (0, 0, 0, 0)
		_MainTex ("Transition Texture", 2D) = "gray" {}
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue" = "Overlay+5000" "IgnoreProjector" = "True" }
		Pass {
			Blend DstColor Zero
			ZTest Always
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			
			struct appdata {
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = float4(2 * v.uv.x - 1, 1 -  2 * v.uv.y, 0, 1);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = saturate(tex2D(_MainTex, i.uv) + _Color * 2 - 1);
				return c;
			}
			ENDCG			
		}
	} 
}
