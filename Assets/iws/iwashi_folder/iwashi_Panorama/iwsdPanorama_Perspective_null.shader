// iwsd panorama shader
// for six sided camera system
//
// Copyright naqtn. MIT license
//

Shader "iwsd/Panorama_SingleCamera_null" {
    
    Properties {
        [NoScaleOffset] _MainTex ("MainTex", 2D) = "gray" {}

        _FovInDegrees ("Texture FOV in degres", Range(1,179) ) = 90
		_OutOfRangeColor ("OutOfRange Color", Color) = (.5, .5, .5, .5)
	
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Culling face (CullMode)", Float) = 1

		_ObjectCenterWeight ("Object center weight", Range(0,1) ) = 0
        _ObjectDirectionWeight ("Object space direction weight", Range(0,1) ) = 0
        _RotationYInDegrees ("Y-axis rotation", Range(0,360) ) = 0

        [MaterialToggle] _Flipped ("Flipped", Float ) = 0
		[MaterialToggle] _CameraRotation ("Camera Rotation", Float ) = 0

        [MaterialToggle] _GammaToLinear ("GammaToLinear(degamma)", Float ) = 0
    }
    
    SubShader {

		Tags {
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

        Pass {
            Cull [_Cull]
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
	    
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0 // for texture LOD sampling (tex2Dlod)
            
            #include "UnityCG.cginc"
            #include "iwsdPanoramaFuncs.cginc"

			sampler2D _MainTex;
			half4 _OutOfRangeColor;
			fixed _FovInDegrees;
            fixed _ObjectCenterWeight;
            fixed _ObjectDirectionWeight;
			fixed _RotationYInDegrees;
            fixed _Flipped;
			fixed _GammaToLinear;
			fixed _CameraRotation;
            
			struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
				float4 dirModel : TEXCOORD1;
            };

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.dirModel = v.vertex - float4(0,0,0,1);
                return o;
            }

			fixed4 frag(v2f i) : SV_Target {
				float3 origin = lerp(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz, _ObjectCenterWeight );
				float3 direction = lerp(i.posWorld.xyz - origin.xyz, i.dirModel.xyz, _ObjectDirectionWeight);
				
				fixed3x3 inverseRotation = fixed3x3(normalize(unity_WorldToObject[0].xyz), normalize(unity_WorldToObject[1].xyz), normalize(unity_WorldToObject[2].xyz));
				
				direction = RotateYInDegrees(direction, _RotationYInDegrees);
				direction = mul(inverseRotation, direction);
				direction = lerp(direction, mul(UNITY_MATRIX_V, direction), _CameraRotation);
				direction = direction * lerp(float3(+1,+1,+1), float3(+1,+1,-1), _Flipped);

				float fovInRad = _FovInDegrees * UNITY_PI / 180.0;
				fixed4 col = Project2Tex(direction, fovInRad, _MainTex, _OutOfRangeColor);
		
				if (_GammaToLinear > 0) {
					col.rgb = GammaToLinearSpace(col.rgb);
				}

                return col;
            }

            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
