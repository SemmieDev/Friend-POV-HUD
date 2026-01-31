Shader "SemmieDev/Friend POV HUD" {
    Properties {
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Range(0, 1)) = 1
        _X ("X", Range(-1, 1)) = 0
        _Y ("Y", Range(-1, 1)) = 0
    }

    SubShader {
        Tags {
            "RenderType" = "Opaque"
            "Queue" = "Overlay"
        }

        Cull Off
        ZTest Always
        ZWrite Off
        Fog { Mode Off }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float _Scale;
            float _X;
            float _Y;
            float _VRChatCameraMode;
            float _VRChatMirrorMode;
            float _VRChatFaceMirrorMode;

            v2f vert(appdata v) {
                v2f o;

                if (
                    _VRChatCameraMode != 0 ||
                    _VRChatMirrorMode != 0 ||
                    _VRChatFaceMirrorMode != 0 ||
                    (_ScreenParams.x == 512 && _ScreenParams.y == 512)
                ) {
                    o.pos = 0;
                    o.uv = 0;
                    return o;
                }

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float near_height = _ProjectionParams.y / UNITY_MATRIX_P._m11;
                float near_width = near_height * (_ScreenParams.x / _ScreenParams.y);

                float scale = max(near_width, near_height) * _Scale;
                float2 pos = v.pos.xy * -2 * scale + (float2(near_width, near_height) - scale) * float2(_X, _Y);

                o.pos = UnityViewToClipPos(float3(pos, -_ProjectionParams.y));
                o.uv = v.uv;

                return o;
            }

            float4 frag(v2f i) : SV_Target {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}