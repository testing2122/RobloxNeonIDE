# NeonIDE

A sleek, modern IDE-style UI library for Roblox with code editor and AI chat functionality. 

## Features

- Modern Dark Theme with Purple Glow Accents
- Code Editor with Syntax Highlighting
- AI Chat Interface
- Smooth Animations & Transitions
- Fully Modular Component System

## Usage

```lua
-- Load the main library
local NeonIDE = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/init.lua"))()

-- Create and show a new instance
local myIDE = NeonIDE.new()
myIDE:show()
```

## Components

- **CodeEditor** - Syntax highlighting, line numbers, and code editing
- **AiChat** - Interactive AI assistant interface
- **TabSystem** - Manage multiple files or tabs
- **Theming** - Easy customization options

## Animation System

NeonIDE uses a spring-based animation system for smooth, responsive UI interactions.

## Example

See the [example.lua](https://github.com/testing2122/RobloxNeonIDE/blob/main/examples/example.lua) file for complete setup code.