Shader "Hidden/Gaussian Blur Filter"
{
    Properties
    {
        _MainTex("", 2D) = "white" {}
        _BaseTex("", 2D) = "white" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    sampler2D _BaseTex;
    float4 _BaseTex_TexelSize;

    float _Scale;

    half4 frag_reduce(v2f_img i) : SV_Target
    {
        float4 d = _MainTex_TexelSize.xyxy * float4(-1, -1, +1, +1);
        float4 s;
        s  = tex2D(_MainTex, i.uv + d.xy);
        s += tex2D(_MainTex, i.uv + d.zy);
        s += tex2D(_MainTex, i.uv + d.xw);
        s += tex2D(_MainTex, i.uv + d.zw);
        return s * 0.25;
    }

    half4 frag_expand(v2f_img i) : SV_Target
    {
        float4 d = _MainTex_TexelSize.xyxy * float4(1, 1, -1, 0) * _Scale;
        float4 s;

        s  = tex2D(_MainTex, i.uv - d.xy);
        s += tex2D(_MainTex, i.uv - d.wy) * 2;
        s += tex2D(_MainTex, i.uv - d.zy);

        s += tex2D(_MainTex, i.uv + d.zw) * 2;
        s += tex2D(_MainTex, i.uv       ) * 4;
        s += tex2D(_MainTex, i.uv + d.xw) * 2;

        s += tex2D(_MainTex, i.uv + d.zy);
        s += tex2D(_MainTex, i.uv + d.wy) * 2;
        s += tex2D(_MainTex, i.uv + d.xy);

        return s * (1.0 / 16) + tex2D(_BaseTex, i.uv);
    }

    ENDCG

    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_reduce
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_expand
            #pragma target 3.0
            ENDCG
        }
    }
}
