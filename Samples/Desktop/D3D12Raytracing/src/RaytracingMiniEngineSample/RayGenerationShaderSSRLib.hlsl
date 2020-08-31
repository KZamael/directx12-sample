/** Original Ideas have the Microsoft Copyright and are from https://github.com/microsoft/DirectX-Graphics-Samples/tree/master/Samples/Desktop/D3D12Raytracing
*   This Implementation is for studying reflections for the bachelor thesis.
**/

#define HLSL

#include "ModelViewerRaytracing.h"

Texture2D<float>    depth    : register(t12);
Texture2D<float4>   normals  : register(t13);

[shader("raygeneration")]
void RayGen()
{
    // provides the 2D coordinates of the current pixel.
    uint2 DTid = DispatchRaysIndex().xy;
    float2 xy = DTid.xy + 0.5; // position + offset

    // Screen position for the ray
    float2 screenPos = xy / g_dynamic.resolution * 2.0 - 1.0;

    // Invert y for DirectX-style coordinates - "not -="
    screenPos.y = -screenPos.y;

    // Read depth and normal, and read from Graphicbuffer at position xy
    float4 dataNormals = normals.Load(int3(xy, 0));
    float sceneDepth = depth.Load(int3(xy, 0));
    if (dataNormals.w == 0.0)
        return;

#ifdef VALIDATE_NORMAL
    // Check if normal is real and non-zero
    float lengthSquared = dot(dataNormals.xyz, dataNormal.xyz);
    if (!isfinite(lengthSquared) || lengthSquared < 1e-6)
        return;
    float3 normal = dataNormals.xyz * rsqrt(lenthSquared);
#else
    float3 normal = dataNormals.xyz;
#endif

    // Unproject into the world position using depth
    float4 unprojected = mul(g_dynamic.cameraToWorld, float4(screenPos, sceneDepth, 1));
    float3 worldMat = unprojected.xyz / unprojected.w;
    float3 primaryRayDirection = normalize(g_dynamic.worldCameraPosition - worldMat);

    // Define the rays origin in the world coordinate system.
    float3 origin = worldMat - primaryRayDirection * 0.2f;

    // Reflection Formula via dot product https://en.m.wikipedia.org/wiki/Reflection_(mathematics)#Reflection_across_a_line_in_the_plane
    float3 reflection = 2 * dot(-primaryRayDirection, normal);
    
    // Normalize the reflection difference between negative generated rays and the reflection for the reflections mirrored direction.
    float3 d = normalize(-primaryRayDirection - reflection * normal); 

    RayDesc rayDesc = { origin,
        0.0f,
        d,
        FLT_MAX };

    // For input and output, when invoked by shaders during Raytracing.
    RayPayload rayPayload;
    rayPayload.SkipShading = false;
    rayPayload.RayHitT = FLT_MAX; // Largest possible floating point number.
    TraceRay(g_accelerationStructure, RAY_FLAG_CULL_BACK_FACING_TRIANGLES, ~0,0,1,0, rayDesc, rayPayload);
}

