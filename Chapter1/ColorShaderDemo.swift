import SwiftUI

// doc metal shading language: https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf

// MARK: Solid color
struct ColorShaderDemo: View {
    var body: some View {
        VStack {
            
            // Using fill
            let fillOrange = ShaderLibrary.fillOrangeColor()
            
            Rectangle()
                .fill(fillOrange)
            
            // Apply direct
            Rectangle()
                .colorEffect(ShaderLibrary.fillRedColor())
            
            // Apply with visual Effect
            Rectangle()
                .visualEffect { content, proxy in
                    content
                        .colorEffect(ShaderLibrary.fillGreenColor())
                }
            
            // Apply with canvas
            Canvas { ctx, size in
                // Create a rectangle the size of the Canvas
                let rect = CGRect(origin: .zero, size: size)
                
                // Use the shader with coordinates
                let shader = Shader(function: ShaderLibrary.fillBlueColor,
                                    arguments: [
                                        .float2(Float(size.width), Float(size.height))
                                    ])
                
                ctx.fill(Path(rect), with: .shader(shader))
            }
            
            
        }
    }
}

#Preview("Solid color") {
    ColorShaderDemo()
}

// MARK: Custom color
struct ColorBlendDemo: View {
    @State var colorOne: Color = .red
    @State var colorTwo: Color = .yellow
    
    private func applyColor(_ color: Color) -> Shader {
        return Shader(function: .init(library: .default, name: "fillColor"), arguments: [
            .color(color)
        ])
    }
    
    private func blendColor(from color1: Color, to color2: Color) -> Shader {
        return Shader(function: .init(library: .default, name: "colorBlend"), arguments: [
            .color(color1), // bottomColor
            .color(color2)  // topColor
        ])
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 100)
                .colorEffect(blendColor(from: colorOne, to: colorTwo))
            
            HStack {
                Rectangle()
                    .frame(height: 100)
                    .colorEffect(applyColor(colorOne))
                
                ColorPicker("Color 1", selection: $colorOne)
            }
            HStack {
                Rectangle()
                    .frame(height: 100)
                    .colorEffect(applyColor(colorTwo))
                
                ColorPicker("Color 2", selection: $colorTwo)
            }
        }
        .padding()
    }
}
#Preview("Custom color") {
    ColorBlendDemo()
}

// MARK: Flag
struct FlagsDemoView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Italy 🇮🇹")
            Rectangle()
                .visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.italyFlag(
                                .boundingRect
                            )
                        )
                }
                .border(Color.gray, width: 1)
            
            Text("Germany 🇩🇪")
            Rectangle()
                .visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.germanyFlag(
                                .boundingRect
                            )
                        )
                }
                .border(Color.gray, width: 1)
            
            
            Text("Japan 🇯🇵")
            Rectangle()
                .visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.japanFlag(
                                .boundingRect
                            )
                        )
                }
                .border(Color.gray, width: 1)
            
        }
        .padding()
    }
}

#Preview("Flags") {
    FlagsDemoView()
}


#Preview("Stripes") {
    
    VStack {
        let fill = ShaderLibrary.Stripes(
            .float(20),
            .colorArray([
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )

        Circle().fill(fill)
    }
    .padding()
}
