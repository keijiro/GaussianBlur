using UnityEngine;

[ExecuteInEditMode]
public class FilterTest : MonoBehaviour
{
    [SerializeField, HideInInspector]
    Shader _shader;

    [SerializeField, Range(0, 8)]
    int _iteration = 4;

    [SerializeField]
    bool _naive;

    Material _material;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material == null)
        {
            _material = new Material(_shader);
            _material.hideFlags = HideFlags.HideAndDontSave;
        }

        if (_naive)
            _material.EnableKeyword("_NAIVE");
        else
            _material.DisableKeyword("_NAIVE");

        RenderTexture rt1, rt2;

        rt1 = RenderTexture.GetTemporary(source.width, source.height);
        rt2 = RenderTexture.GetTemporary(source.width, source.height);

        Graphics.Blit(source, rt1);

        for (var i = 0; i < _iteration; i++)
        {
            Graphics.Blit(rt1, rt2, _material, 0);
            Graphics.Blit(rt2, rt1, _material, 1);
        }

        Graphics.Blit(rt1, destination);

        RenderTexture.ReleaseTemporary(rt1);
        RenderTexture.ReleaseTemporary(rt2);
    }
}
