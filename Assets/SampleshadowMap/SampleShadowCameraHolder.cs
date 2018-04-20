using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SampleShadowCameraHolder : MonoBehaviour {

    // Use this for initialization
    [SerializeField]
    Light mainDirectionLight = null;

    Camera LightSpaceCamera = null;
    [SerializeField]
    Shader SampleShadowSH = null;

    [SerializeField]
    RenderTexture shadowRT;
    void Start () {
		if(mainDirectionLight == null)
        {
            Debug.LogError("MainDirectionLight is null");
            return;
        }
        this.transform.rotation =  mainDirectionLight.transform.rotation;
        LightSpaceCamera = GetComponent<Camera>();


        Matrix4x4 mv = LightSpaceCamera.worldToCameraMatrix;
        Matrix4x4 prj = GL.GetGPUProjectionMatrix(LightSpaceCamera.projectionMatrix, false);
        Matrix4x4 LightSpaceMvp = prj * mv;
        Shader.SetGlobalMatrix("_LightProjection", LightSpaceMvp);

        Shader.SetGlobalTexture("_LightDepthTex", shadowRT);
        LightSpaceCamera.SetReplacementShader(SampleShadowSH, "RenderType");
    }
	
    private void OnPostRender()
    {
        gameObject.SetActive(false);
    }




}
