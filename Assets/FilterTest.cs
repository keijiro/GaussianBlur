using UnityEngine;

[ExecuteInEditMode]
public class FilterTest : MonoBehaviour
{
    [SerializeField, Range(0, 10)] float _scale = 1.0f;
    [SerializeField, HideInInspector] Shader _shader;

    Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null)
        {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.HideAndDontSave;
        }

        var hlog = Mathf.Log(Screen.height, 2) + _scale - 5;
        var icount = Mathf.Max(2, (int)hlog);
        _material.SetFloat("_Scale", 0.5f + hlog - (int)hlog);

        var rt1 = new RenderTexture[icount];
        var rt2 = new RenderTexture[icount];
        var tx = source.width;
        var ty = source.height;

        for (var i = 0; i < icount; i++)
        {
            tx /= 2;
            ty /= 2;
            rt1[i] = RenderTexture.GetTemporary(tx, ty);
            rt2[i] = RenderTexture.GetTemporary(tx, ty);
        }

        Graphics.Blit(source, rt1[0], _material, 0);
        for (var i = 1; i < icount; i++)
            Graphics.Blit(rt1[i - 1], rt1[i], _material, 0);

        _material.SetTexture("_BaseTex", rt1[icount - 2]);
        Graphics.Blit(rt1[icount - 1], rt2[icount - 2], _material, 1);

        for (var i = icount - 2; i > 0; i--)
        {
            _material.SetTexture("_BaseTex", rt1[i - 1]);
            Graphics.Blit(rt2[i],  rt2[i - 1], _material, 1);
        }

        _material.SetTexture("_BaseTex", source);
        Graphics.Blit(rt2[0], destination, _material, 1);

        for (var i = 0; i < icount; i++)
        {
            RenderTexture.ReleaseTemporary(rt1[i]);
            RenderTexture.ReleaseTemporary(rt2[i]);
        }
    }
}
