// Vanilla depth of field.

#ifdef __INTELLISENSE__
    #define PS
#endif

struct VertexData {
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
};

struct VertexOutput {
    float4 positionSS : POSITION;
    float2 uv : TEXCOORD0;
};

struct PixelInput {
    float2 uv : TEXCOORD0;
};

struct PixelOutput {
    float4 shadedPixel : COLOR0;
};

#ifdef VS

float4 geometryOffset : register(c0);
float4 texOffset0 : register(c1);
float4 texOffset1 : register(c2);

VertexOutput Main(VertexData vertex) {
    VertexOutput output;
    
    // Apply geometry offset with scaling factor of (-2, 2)
    output.positionSS.xy = geometryOffset.xy * float2(-2.0, 2.0) + vertex.position.xy;
    output.positionSS.zw = vertex.position.zw;
    
    // Add texture offsets to base texture coordinates
    output.uv = vertex.uv + texOffset0.xy;
    
    return output;
}

#else

sampler2D Image : register(s0);
sampler2D Blurred : register(s1);
sampler2D Depth : register(s2);

float4 Params0 : register(c0);
float4 Params1 : register(c1);
float4 DepthParams : register(c2);

PixelOutput Main(PixelInput input) {
    PixelOutput output;
    
    // Sample depth buffer
    float depth = tex2Dlod(Depth, float4(input.uv.xy, 0.0f, 0.0f)).r;
    
    // Convert NDC Z back to view space depth
    // Formula: view_z = (near*far) / (ndc_z*(far-near) + near)
    float viewDepth = DepthParams.w / (depth * DepthParams.z + DepthParams.y);
    viewDepth *= 0.0001;  // Scale to values comparable to vanilla depth render.
    
    // Exclude sky pixels.
    if (depth < 0.0000001f) {
        viewDepth = 1.0f;
    }
    
    // Vanilla math
    float2 mask = -(Params1.yz * Params1.yz) >= 0 ? 0.0f : 1.0f;
    
    float nearTest = viewDepth * Params0.w - Params0.z;
    float farTest = viewDepth * (-Params0.w) + Params0.z;
    
    float nearMask = (nearTest >= 0.0) ? 0.0f : 1.0f;
    mask.x *= nearMask;
    
    float farMask = (farTest >= 0.0) ? 0.0f : 1.0f;
    mask.y *= farMask;
    
    float2 range = float2(Params0.z - Params0.x, Params0.y - Params0.z);
    range = 1.0 / range;
    
    nearTest *= range.y;
    farTest *= range.x;
    
    float nearBlend = (-mask.x >= 0.0) ? 0.0f : farTest;
    float blendFactor = saturate((-mask.y >= 0.0) ? nearBlend : nearTest);
    
    blendFactor *= Params1.x;
    
    float4 blurredColor = tex2Dlod(Blurred, float4(input.uv.xy, 0.0f, 0.0f));
    float4 originalColor = tex2Dlod(Image, float4(input.uv.xy, 0.0f, 0.0f));
    
    output.shadedPixel = lerp(originalColor, blurredColor, blendFactor);
    
    return output;
}

#endif