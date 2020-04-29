#ifndef __SKYUTILS_H__
#define __SKYUTILS_H__

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

float4x4 _PixelCoordToViewDirWS;

#if defined(USING_STEREO_MATRICES)
    #define _PixelCoordToViewDirWS  _XRPixelCoordToViewDirWS[unity_StereoEyeIndex]
#endif

// Generates a world-space view direction for sky and atmospheric effects
float3 GetSkyViewDirWS(float2 positionCS)
{
    float4 viewDirWS = mul(float4(positionCS.xy + _TaaJitterStrength.xy, 1.0f, 1.0f), _PixelCoordToViewDirWS);
    return normalize(viewDirWS.xyz);
}

// Returns latlong coords from view direction
float2 GetLatLongCoords(float3 dir, float upperHemisphereOnly)
{
    const float2 invAtan = float2(0.1591, 0.3183);
    float2 uv = float2(atan2(dir.x, dir.z), asin(dir.y));
    uv = uv * invAtan + 0.5;
    uv.y = lerp(uv.y, uv.y * 2.0 - 1.0, upperHemisphereOnly);
    return uv;
}

// Generates a flow for a constant wind in the z direction
// source: https://www.gdcvault.com/play/1020146/Moving-the-Heavens-An-Artistic
float2 GenerateFlow(float3 dir)
{
    float3 d = float3(0, 1, 0) - dir;
    return (dir.y > 0) * normalize(d - dot(d, dir) * dir).zx;
}

#endif // __SKYUTILS_H__
