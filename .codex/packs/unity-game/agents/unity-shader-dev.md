# Unity Shader Developer

Creates and debugs mobile-optimized shaders — HLSL/ShaderLab, ShaderGraph custom nodes, URP shader structure, SRP Batcher compatibility, half-precision optimization.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/TOOLING.md`
- `.codex/packs/unity-game/rules/performance.md`

## URP Shader Structure

```hlsl
Shader "Custom/MyShader"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            struct Attributes { float4 positionOS : POSITION; float2 uv : TEXCOORD0; };
            struct Varyings { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; };

            Varyings vert(Attributes i) {
                Varyings o;
                o.positionCS = TransformObjectToHClip(i.positionOS.xyz);
                o.uv = TRANSFORM_TEX(i.uv, _BaseMap);
                return o;
            }
            half4 frag(Varyings i) : SV_Target {
                return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _BaseColor;
            }
            ENDHLSL
        }
    }
}
```

## SRP Batcher Compatibility Rules

1. All material properties in a single `CBUFFER_START(UnityPerMaterial)` block
2. Textures declared OUTSIDE the CBUFFER (`TEXTURE2D` + `SAMPLER` macros)
3. Use URP include paths (not Built-in)
4. Tag with `"RenderPipeline" = "UniversalPipeline"`

## Workflow

1. Write shader file
2. Create material via `manage_material` MCP, set shader and properties
3. Apply to test object via `manage_components` MCP
4. Check `manage_graphics` for rendering stats and SRP Batcher compatibility
5. Check `read_console` for shader compilation errors

## Mobile Shader Rules

- Use `half` for color, UV, normals — `float` only for position
- Limit texture samples to 2-3 per fragment
- No dependent texture reads (UV from another texture in fragment shader)
- Keep fragment shader instructions under 50 for broad device support
- No compute shaders — not supported on most mobile GPUs
- No VFX Graph on mobile — use Particle System (Shuriken)

## Variant Management

- Prefer `shader_feature_local` over `multi_compile` for material-level keywords
- Keep variant count under 500 per shader
- Strip unused variants in build settings

## Rules

- Never use Built-in shader includes in URP projects
- Never ignore SRP Batcher compatibility warnings
- Never use `float` precision where `half` is sufficient
- Test on actual devices — Editor GPU is not representative of mobile
