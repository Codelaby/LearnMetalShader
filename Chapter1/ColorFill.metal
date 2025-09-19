#include <metal_stdlib>
using namespace metal;

//MARK: Basic Colors
[[ stitchable ]]
half4 fillRedColor(float2 position, half4 color) {
    // Opaque red: R=1, G=0, B=0, A=1
    return half4(1.0h, 0.0h, 0.0h, 1.0h);
}

[[ stitchable ]]
half4 fillGreenColor(float2 position, half4 color) {
    // Opaque green: R=0, G=1, B=0, A=1
    return half4(0.0h, 1.0h, 0.0h, 1.0h);
}

[[ stitchable ]]
half4 fillBlueColor(float2 position, half4 color) {
    // Opaque blue: R=0, G=0, B=1, A=1
    return half4(0.0h, 0.0h, 1.0h, 1.0h);
}

// Returns an opaque (alpha == 1) color from the r, g, and b arguments.
inline half4 makeRGB(int r, int g, int b) {
    return half4(static_cast<float>(r)/255.0, // red
                 static_cast<float>(g)/255.0, // green
                 static_cast<float>(b)/255.0, // blue
                 1.0); // alpha
}

// MARK: For fill method
// Using constants
constant const half4 orange = makeRGB(237, 172, 76);

[[ stitchable ]]
half4 fillOrangeColor(float2 position) {
    return orange;
}

// MARK: Color Parameter
// Custom Color by argument
[[ stitchable ]]
half4 fillColor(
    float2 position,
    half4 currentColor,
    half4 newColor
) {
    return newColor;
}

// OPCIÓN 1: Color mix 50/50
inline half4 colorHalfMix(half4 bottomColor, half4 topColor) {
    half3 blended = mix(bottomColor.rgb, topColor.rgb, 0.5);
    return half4(blended, 1.0);
}

// Stitchable shader usando mezcla simple
[[ stitchable ]]
half4 colorBlend(float2 position, half4 currentColor, half4 bottomColor, half4 topColor) {
    return colorHalfMix(bottomColor, topColor);
}

// MARK: Stripes
[[ stitchable ]]
half4 Stripes(float2 position,
    float thickness,          // Thickness of each stripe
    device const half4 *ptr,  // Pointer to color array in device memory (GPU memory)
    int count                 // Number of colors in the array
) {
    // Calculate which stripe we're in based on vertical position
    int i = int(floor(position.y / thickness));

    // Clamp to 0 ..< count.
    // This ensures the index stays within valid array bounds
    // using modulo arithmetic to handle both positive and negative values
    i = ((i % count) + count) % count;

    // Return the color from the device memory array
    return ptr[i];
}

// MARK: Flags
// Italy Flag - Vertical tricolor
[[ stitchable ]] half4 italyFlag(float2 position, half4 currentColor,
    float4 bounds
) {
    float width = bounds.z;          // rect.width
    float third = width / 3.0;

    if (position.x < third) {
        return half4(0.0, 146.0/255.0, 70.0/255.0, 1.0); // Green
    } else if (position.x < 2.0 * third) {
        return half4(1.0, 1.0, 1.0, 1.0); // White
    } else {
        return half4(206.0/255.0, 43.0/255.0, 55.0/255.0, 1.0); // Red
    }
}

[[ stitchable ]] half4 germanyFlag(float2 position, half4 currentColor, float4 bounds) {
    float height = bounds.w;         // rect.height
    float third = height / 3.0;

    if (position.y < third) {
        return half4(0.0, 0.0, 0.0, 1.0); // Black
    } else if (position.y < 2.0 * third) {
        return half4(1.0, 0.0, 0.0, 1.0); // Red
    } else {
        return half4(1.0, 204.0/255.0, 0.0, 1.0); // Gold
    }
}

[[ stitchable ]] half4 japanFlag(float2 position, half4 currentColor, float4 bounds) {
    float2 size = float2(bounds.z, bounds.w);
    float2 center = size / 2.0;
    float radius = min(size.x, size.y) * 0.3;
    float distance = length(position - center);

    if (distance < radius) {
        return half4(188.0/255.0, 0.0, 45.0/255.0, 1.0); // Red circle
    } else {
        return half4(1.0, 1.0, 1.0, 1.0); // White
    }
}
