#define HLSL
#include "ModelViewerRaytracing.h"

Texture2D<float>    depth    : register(t12);

[shader("raygeneration")]
void RayGen()
{
    uint2 DTid = DispatchRaysIndex().xy;
    float2 xy = DTid.xy + 0.5;

    // Screen position for the ray
    float2 screenPos = xy / g_dynamic.resolution * 2.0 - 1.0;

    // Invert Y for DirectX-style coordinates
    screenPos.y = -screenPos.y;

    float2 readGBufferAt = xy;

    // Read depth and normal
    float sceneDepth = depth.Load(int3(readGBufferAt, 0));

    // Unproject into the world position using depth
    float4 unprojected = mul(g_dynamic.cameraToWorld, float4(screenPos, sceneDepth, 1));
    float3 world = unprojected.xyz / unprojected.w;

    float3 direction = SunDirection;
    float3 rayOrigin = world;

    RayDesc rayDesc = { rayOrigin,
        0.0f,
        direction,
        FLT_MAX };
    RayPayload payload = { false, FLT_MAX };
    TraceRay(g_accelerationStructure, RAY_FLAG_ACCEPT_FIRST_HIT_AND_END_SEARCH, ~0,0,1,0, rayDesc, payload);

    if (payload.RayHitT < FLT_MAX)
    {
        g_screenOutput[DispatchRaysIndex().xy] = float4(0, 0, 0, 1);
    }
    else
    {
        g_screenOutput[DispatchRaysIndex().xy] = float4(1, 1, 1, 1);
    }
}

