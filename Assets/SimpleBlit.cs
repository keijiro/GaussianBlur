using UnityEngine;

[ExecuteInEditMode]
public class SimpleBlit : MonoBehaviour
{
    [SerializeField]
    Texture2D _baseTexture;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(_baseTexture, destination);
    }
}
