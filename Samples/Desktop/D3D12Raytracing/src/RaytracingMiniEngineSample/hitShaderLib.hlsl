/** Original ideas have the Microsoft Copyright and are from https://github.com/microsoft/DirectX-Graphics-Samples/tree/master/Samples/Desktop/D3D12Raytracing
*   This Implementation is for studying raytracing or the bachelor thesis.
**/

#define HLSL
#include "ModelViewerRaytracing.h"

[shader("closesthit")]
void Hit(inout RayPayload rayPayload, in BuiltInTriangleIntersectionAttributes attr)
{
    rayPayload.RayHitT = RayTCurrent();
    if (!rayPayload.SkipShading)
    {
        g_screenOutput[DispatchRaysIndex().xy] = float4(attr.barycentrics, 1, 1);
    }
}


