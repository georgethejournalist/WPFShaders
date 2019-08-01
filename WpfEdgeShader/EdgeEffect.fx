sampler2D imageSampler : register(s0);
float imageWidth : register(c0);
float imageHeight : register(c1);
float threshold : register(c2);

static const float2x3 op =
{
    1.0f, 2.0f, 1.0f,
    -1.0f, -2.0f, -1.0f
};

static const float3x3 laplace =
{
    -1.0f, -1.0f, -1.0f,
    -1.0f, 8.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
};

float grayScaleByLumino(float3 color)
{
    return (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
}

// ALSO WORKING!
//float4 OutlinesFunction3x3(float2 input, float2 pixelSize)
//{
//    float4 lum = float4(0.30, 0.59, 0.11, 1);

//    // TOP ROW
//    float s11 = dot(tex2D(imageSampler, input + float2(-pixelSize.x, -pixelSize.y)), lum); // LEFT
//    float s12 = dot(tex2D(imageSampler, input + float2(0, -pixelSize.y)), lum); // MIDDLE
//    float s13 = dot(tex2D(imageSampler, input + float2(pixelSize.x, -pixelSize.y)), lum); // RIGHT

//    // MIDDLE ROW
//    float s21 = dot(tex2D(imageSampler, input + float2(-pixelSize.x, 0)), lum); // LEFT
//    // Omit center
//    float s23 = dot(tex2D(imageSampler, input + float2(pixelSize.x, 0)), lum); // RIGHT

//    // LAST ROW
//    float s31 = dot(tex2D(imageSampler, input + float2(-pixelSize.x, pixelSize.y)), lum); // LEFT
//    float s32 = dot(tex2D(imageSampler, input + float2(0, pixelSize.y)), lum); // MIDDLE
//    float s33 = dot(tex2D(imageSampler, input + float2(pixelSize.x, pixelSize.y)), lum); // RIGHT

//    // Filter ... thanks internet
//    float t1 = s13 + s33 + (2 * s23) - s11 - (2 * s21) - s31;
//    float t2 = s31 + (2 * s32) + s33 - s11 - (2 * s12) - s13;

//    float4 col;

//    if (((t1 * t1) + (t2 * t2)) > threshold)
//    {
//        col = float4(1, 0, 0, 1);
//    }
//    else
//    {
//        col = tex2D(imageSampler, input);
//    }

//    return col;
//}

float4 GetEdgeGeorge(float2 coord, float2 pixelSize)
{
    float4 lum = float4(0.30, 0.59, 0.11, 1);

    float2 current = coord;
    float avrg = 0;

    float kernelValue;
    float4 currentColor;
    float4 resultColor;
    float grayScale;

    float4 result;

    current.x = coord.x - pixelSize.x;
    for (int x = 0; x < 3; x++)
    {
        current.y = coord.y - pixelSize.y;
        for (int y = 0; y < 3; y++)
        {
            kernelValue = laplace[x][y];
            grayScale = grayScaleByLumino(tex2D(imageSampler, current).rgb);
            avrg += grayScale * kernelValue;

            current.y += pixelSize.y;
        }
        current.x += pixelSize.x;
    }
    
    avrg = abs(avrg / 8);

    if (avrg > threshold)
    {
        result = float4(1, 0, 0, 1);
    }
    else
    {
        result = tex2D(imageSampler, coord);
    }

    return result;
}

float4 main(float2 uv : TEXCOORD) : COLOR
{
    float2 pixelSize = (1 / imageWidth, 1 / imageHeight);
    return GetEdgeGeorge(uv, pixelSize);
}