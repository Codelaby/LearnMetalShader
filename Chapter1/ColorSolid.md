# Solid Color Shaders
The most fundamental type of shader is one that ignores its input and returns a constant color.

[![Watch the video](https://img.youtube.com/vi/Di5HLmpDqDo/maxresdefault.jpg)](https://youtube.com/shorts/Di5HLmpDqDo?si=rFl7z7sj1-aZBDwF)

The example below creates a function that paints every pixel it’s applied to an opaque red.

```c++
[[ stitchable ]]
half4 fillRedColor(float2 position, half4 color) {
    return half4(1.0, 0.0, 0.0, 1.0); // Opaque red
}
```

- [[ stitchable ]]: This attribute is crucial for SwiftUI. It tells Metal that this function is a shader designed to work with SwiftUI’s drawing system and can be called from a ShaderLibrary.
- half4: The return type. This represents a four-component color value (Red, Green, Blue, Alpha), where each component is a 16-bit floating-point number (half). It’s efficient and perfectly suitable for most color operations.
- Parameters: The function takes standard parameters SwiftUI provides: the position of the current pixel and the original color of the view at that position.
- Return Value: half4(1.0, 0.0, 0.0, 1.0) constructs a color with full red, no green, no blue, and full opacity (alpha = 1.0).

## Integrating Shaders with SwiftUI
The `.colorEffect` modifier is the simplest way to apply a shader. It’s used for basic color manipulation and replaces the view’s content with the output of the shader function.

```c++
Rectangle()
    .colorEffect(ShaderLibrary.fillRedColor())
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
