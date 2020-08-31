/** Original ideas have the Microsoft Copyright and are from https://github.com/microsoft/DirectX-Graphics-Samples/tree/master/Samples/Desktop/D3D12Raytracing
*   This implementation is for studying raytracing for my bachelor thesis.
**/

#define HLSL
#include "ModelViewerRaytracing.h"


[shader("raygeneration")]
void RayGen()
{
    float3 rayOrigin, direction;
    GenerateCameraRay(DispatchRaysIndex().xy, rayOrigin, direction);

    RayDesc rayDesc = { rayOrigin,
        0.0f,
        direction,
        FLT_MAX };
    RayPayload payload;
    payload.RayHitT = FLT_MAX;
    payload.SkipShading = false;
    TraceRay(g_accelerationStructure, RAY_FLAG_CULL_BACK_FACING_TRIANGLES, ~0,0,1,0, rayDesc, payload);
}

