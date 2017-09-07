using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//utilisable entre-autre pour faire des moniteur, etc.
[ExecuteInEditMode]
public class SimplePostEffect : MonoBehaviour // script à attacher à la caméra
{
    public Material postEffect; // créer un material, dont le shader est un "Image Effect Shader"

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postEffect);
    }

}
