#define HLSL
#include "ModelViewerRaytracing.h"

[shader("miss")]
void Miss(inout RayPayload rayPayload)
{
    if (!rayPayload.SkipShading && !IsReflection)
    {
        g_screenOutput[DispatchRaysIndex().xy] = float4(0, 0, 0, 1);
    }
}

