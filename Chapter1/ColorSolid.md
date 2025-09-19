# Solid Color Shaders
The most fundamental type of shader is one that ignores its input and returns a constant color.

[![Watch the video](https://img.youtube.com/vi/Di5HLmpDqDo/maxresdefault.jpg)](https://youtube.com/shorts/Di5HLmpDqDo?si=rFl7z7sj1-aZBDwF)

The example below creates a function that paints every pixel it's applied to an opaque red.

```c++
[[ stitchable ]]
half4 fillRedColor(float2 position, half4 color) {
    return half4(1.0, 0.0, 0.0, 1.0); // Opaque red
}
```

- `[[ stitchable ]]`: This attribute is crucial for SwiftUI. It tells Metal that this function is a shader designed to work with SwiftUI's drawing system and can be called from a ShaderLibrary.
- `half4`: The return type. This represents a four-component color value (Red, Green, Blue, Alpha), where each component is a 16-bit floating-point number (half). It's efficient and perfectly suitable for most color operations.
- **Parameters**: The function takes standard parameters provided by SwiftUI: the position of the current pixel and the original color of the view at that position.
- **Return Value**: `half4(1.0, 0.0, 0.0, 1.0)` constructs a color with full red, no green, no blue, and full opacity (alpha = 1.0).

## Integrating Shaders with SwiftUI
The `.colorEffect` modifier is the simplest way to apply a shader. It's used for basic color manipulation and replaces the view's content with the output of the shader function.

```swift
Rectangle()
    .colorEffect(ShaderLibrary.fillRedColor())
```

Okay, if you notice that the color argument is not used, we could replace the shader to work with the fill method directly. But first, let's also look at how to create a function that's only available internally and then define a constant to use it in other functions.

```c++
// Returns an opaque (alpha == 1) color from the r, g, and b arguments.
inline half4 makeRGB(int r, int g, int b) {
    return half4(static_cast<float>(r)/255.0, // red
                 static_cast<float>(g)/255.0, // green
                 static_cast<float>(b)/255.0, // blue
                 1.0); // alpha
}

// Using constants
constant const half4 orange = makeRGB(237, 172, 76);

[[ stitchable ]]
half4 fillOrangeColor(float2 position) {
    return orange;
}
```

To apply this in SwiftUI:

```swift
// Using fill
let fillOrange = ShaderLibrary.fillOrangeColor()

Rectangle()
    .fill(fillOrange)
```

## Parameterized Shaders

While solid colors are a good start, the real power of shaders comes from making them dynamic.

[![Watch the video](https://img.youtube.com/vi/kfN8YhzWvB8/maxresdefault.jpg)](https://youtube.com/shorts/kfN8YhzWvB8?si=JYDAcmSySkqmSHQR
)

Parameterized shaders accept input values from your SwiftUI view, allowing you to change their behavior at runtime without modifying the Metal code itself.

```c++
[[ stitchable ]]
half4 fillColor(float2 position, half4 currentColor, half4 newColor) {
    return newColor;
}
```
### Calling Shaders with Arguments

This pattern is used to pass dynamic data from your SwiftUI view to your Metal shader function. It transforms a static shader into a flexible, reusable component.

```c++
// 1. Create a function that builds a Shader with arguments
private func applyColor(_ color: Color) -> Shader {
    return Shader(function: .init(library: .default, name: "fillColor"), arguments: [
        .color(color) // Maps SwiftUI Color to a Metal half4
    ])
}
 
// 2. Use the function to apply the shader with a specific value
Rectangle()
    .frame(height: 100)
    .colorEffect(applyColor(.yellow)) // Passes yellow to the shader
```
- Shader Builder: The applyColor function constructs a Shader object, specifying the function name and its arguments.
- Argument Mapping: The .color() argument type automatically converts a SwiftUI Color into the half4 type that the Metal function expects.
- Dynamic & Reusable: You can call applyColor with any color (e.g., .blue, Color(red: 0.5, green: 0.2, blue: 0.7)), making the same Metal shader code work for infinite scenarios.

Of course. Here is the explanation of how to pass an array of colors as an argument to a Metal shader in SwiftUI, formatted as a code block with detailed comments.

***

### Passing an Array of Colors as a Shader Argument

This shader demonstrates how to create dynamic patterns, like stripes, by passing an array of colors from SwiftUI to a Metal shader. The key is using a pointer to access the array data in the GPU's memory.

```c++
// The 'stitchable' attribute makes this function available to SwiftUI.
[[ stitchable ]]
// Function parameters:
// - position: The coordinates of the current pixel being calculated.
// - thickness: The height (or width) of each individual stripe.
// - ptr: A pointer to the array of color data stored in the GPU's device memory.
// - count: The total number of colors in the array.
half4 Stripes(float2 position,
    float thickness,
    device const half4 *ptr,
    int count
) {
    // 1. Calculate the stripe index:
    // Divide the vertical (y) position by the desired thickness and round down
    // to an integer. This determines which stripe the current pixel belongs to.
    // Example: position.y = 55, thickness = 20 -> i = int(55/20) = 2
    int i = int(floor(position.y / thickness));

    // 2. Safely clamp the index to the array's bounds:
    // This mathematical operation ensures the index 'i' is always between
    // 0 and (count - 1), preventing crashes from accessing invalid memory.
    // The modulo (%) operation wraps the index around if it exceeds the count.
    i = ((i % count) + count) % count;

    // 3. Return the color:
    // Use the calculated and clamped index to look up the correct color
    // from the array in device memory and return it for this pixel.
    return ptr[i];
}
```

**Key Concepts Explained:**

- **`device const half4 *ptr`**: This is the most important parameter.
    - `device`: Specifies that the pointer refers to data in the GPU's dedicated memory (VRAM), which is where SwiftUI places the array you pass from your Swift code.
    - `const`: Promises the shader will not modify the array data (read-only).
    - `half4 *`: A pointer to the first element of an array of `half4` values (our colors).

- **Index Clamping Logic `((i % count) + count) % count`**:
    - `i % count`: Gets the remainder of `i / count`, which wraps the value but can be negative.
    - `+ count`: Ensures the value is positive before the final modulo operation.
    - `% count`: Finally, guarantees the result is a valid index between `0` and `count-1`. This creates a seamless, tiling effect for the stripes.

### SwiftUI Integration:
In your SwiftUI view, you use the `.colorArray` modifier to pass the Swift array of colors to the shader. SwiftUI automatically handles copying this array to the GPU's device memory so the shader's `ptr` parameter can access it.

```swift
#Preview("Stripes") {
    VStack {
        // 1. Initialize the shader with its required arguments:
        let fill = ShaderLibrary.Stripes(
            .float(20), // Pass the 'thickness' argument as a float
            .colorArray([ // Pass the 'ptr' and 'count' arguments using a Swift array
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )
        // 2. Apply the shader using .fill() for a geometric shape
        Circle().fill(fill)
    }
    .padding()
}
```

## Flag Shaders (Complex Patterns)
This code generar a Itally flag, combine position and bounds
[![Watch the video](https://img.youtube.com/vi/JW5ku_GWrPw/maxresdefault.jpg)](https://youtube.com/shorts/JW5ku_GWrPw?si=kL5n4tIkCabdTHTR)

```c++
// Italy Flag - Vertical tricolor
[[ stitchable ]]
half4 italyFlag(float2 position, half4 currentColor, float4 bounds) {
    float width = bounds.z; // Extract the width from bounds
    float third = width / 3.0; // Calculate the size of one stripe
 
    // Use the pixel's x-coordinate to decide which color stripe it's in
    if (position.x < third) {
        return half4(0.0, 146.0/255.0, 70.0/255.0, 1.0); // Green
    } else if (position.x < 2.0 * third) {
        return half4(1.0, 1.0, 1.0, 1.0); // White
    } else {
        return half4(206.0/255.0, 43.0/255.0, 55.0/255.0, 1.0); // Red
    }
}
```
### Understanding position and bounds
The position and bounds parameters are the key to creating dynamic, pattern-based shaders that adapt to the size and location of the view they are applied to.

- float2 position: This is the current pixel’s coordinate that the shader is processing.
- position.x is the horizontal position (from left to right).
- position.y is the vertical position (from bottom to top in Metal’s coordinate system).

The shader runs once for every pixel, and position tells you which pixel you’re on.
float4 bounds: This parameter represents the bounding rectangle of the view being drawn. Its components are:
- bounds.x = x-origin (usually 0)
- bounds.y = y-origin (usually 0)
- bounds.z = width of the view
- bounds.w = height of the view

You use `bounds.z` and `bounds.w` to make calculations relative to the view’s size (e.g., dividing the width into thirds for flag stripes).
How It Works Together: The shader uses the view’s total width (from bounds) to calculate how wide each stripe should be. Then, for each position, it checks the pixel’s x-coordinate to see which stripe it falls into and returns the corresponding color. This creates a perfect, resizable flag pattern.

### How to use in SwiftUI
```swift
Rectangle()
    .colorEffect(ShaderLibrary.italyFlag(.boundingRect))
```
A special argument provided by SwiftUI. Passing .boundingRect automatically sends the view’s bounds (x, y, width, height) as a float4 to the shader’s corresponding parameter.


