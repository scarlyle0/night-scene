# Night Scene — Low Poly Style Prototype

A proof-of-concept atmospheric night scene built in Unity (URP), exploring a stylized
low poly look with a moody feel.

## Purpose

This is a **style prototype**, not a game. The goal was to lock in a coherent low
poly night aesthetic

## Contents

- **Custom toon shader (HLSL / URP)** — stepped three-tone diffuse lighting with
  per-material color control.
- **Moonlit lighting setup** — a single cold directional light with deep, controlled
  shadow color driving the night mood, rather than physically accurate illumination.
- **Post-processing stack** — bloom, ACES tonemapping, color adjustments, and vignette.
- **Mesh particle clouds** — low poly cloud meshes emitted through a particle system
  for continuous, slow horizontal drift.
- **Procedural starfield skybox** — a custom gradient skybox shader with procedurally
  generated, independently twinkling stars.
- **Emissive-by-illusion** — warm "glowing" windows achieved with unlit bright color
  plus bloom rather than real light sources.
