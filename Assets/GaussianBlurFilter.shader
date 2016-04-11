Shader "Hidden/Gaussian Blur Filter"
{
    Properties
    {
        _MainTex("-", 2D) = "white" {}
    }

    CGINCLUDE

    #pragma multi_compile _ _NAIVE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    half4 gaussian_filter(float2 uv, float2 stride)
    {
        const float _k1 = 3432;
        const float _k2 = 3003;
        const float _k3 = 2002;
        const float _k4 = 1001;
        const float _k5 = 364;
        const float _k6 = 91;
        const float _k7 = 14;

        const float ksum = _k1 + (_k2 + _k3 + _k4 + _k5 + _k6 + _k7) * 2;

        const float k1 = _k1 / ksum;
        const float k2 = _k2 / ksum;
        const float k3 = _k3 / ksum;
        const float k4 = _k4 / ksum;
        const float k5 = _k5 / ksum;
        const float k6 = _k6 / ksum;
        const float k7 = _k7 / ksum;

        half4 s = 0;

        s += tex2D(_MainTex, uv + stride * 0) * k1;

        s += tex2D(_MainTex, uv - stride * 1) * k2;
        s += tex2D(_MainTex, uv + stride * 1) * k2;

        s += tex2D(_MainTex, uv - stride * 2) * k3;
        s += tex2D(_MainTex, uv + stride * 2) * k3;

    #if _NAIVE

        s += tex2D(_MainTex, uv - stride * 3) * k4;
        s += tex2D(_MainTex, uv + stride * 3) * k4;

        s += tex2D(_MainTex, uv - stride * 4) * k5;
        s += tex2D(_MainTex, uv + stride * 4) * k5;

        s += tex2D(_MainTex, uv - stride * 5) * k6;
        s += tex2D(_MainTex, uv + stride * 5) * k6;

        s += tex2D(_MainTex, uv - stride * 6) * k7;
        s += tex2D(_MainTex, uv + stride * 6) * k7;

    #else

        const float d1 = (3 * k4 + 4 * k5) / (k4 + k5);
        s += tex2D(_MainTex, uv - stride * d1) * (k4 + k5);
        s += tex2D(_MainTex, uv + stride * d1) * (k4 + k5);

        const float d2 = (5 * k6 + 6 * k7) / (k6 + k7);
        s += tex2D(_MainTex, uv - stride * d2) * (k6 + k7);
        s += tex2D(_MainTex, uv + stride * d2) * (k6 + k7);

    #endif

        return s;
    }

    // Separable Gaussian filters
    half4 frag_blur_h(v2f_img i) : SV_Target
    {
        return gaussian_filter(i.uv, float2(_MainTex_TexelSize.x, 0));
    }

    half4 frag_blur_v(v2f_img i) : SV_Target
    {
        return gaussian_filter(i.uv, float2(0, _MainTex_TexelSize.y));
    }

    ENDCG

    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_blur_h
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_blur_v
            #pragma target 3.0
            ENDCG
        }
    }
}
