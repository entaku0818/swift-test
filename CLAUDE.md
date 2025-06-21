# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dual-purpose Swift Package that demonstrates:
1. **SwiftProtocolsExample** - Educational examples of Swift protocol implementations
2. **OpenAPIClientGenerator** - Practical examples of Swift OpenAPI Generator usage with build-time code generation

## Key Commands

### Building and Testing
```bash
# Build all targets
swift build

# Run all tests
swift test

# Run tests for specific target
swift test --filter SwiftProtocolsExampleTests
swift test --filter OpenAPIClientGeneratorTests

# Clean build artifacts (including generated OpenAPI code)
swift package clean
```

### OpenAPI Code Generation
The OpenAPIClientGenerator target uses build plugins to generate code at build time. Generated files are located in:
`.build/plugins/outputs/swift-test/OpenAPIClientGenerator/destination/OpenAPIGenerator/GeneratedSources/`

Key generated files:
- `Types.swift` - Swift types from OpenAPI schemas
- `Client.swift` - HTTP client implementation
- `Server.swift` - Server protocol definitions

## Architecture

### Two-Target Structure

#### SwiftProtocolsExample Target
Educational module demonstrating protocol-oriented programming patterns:
- **Protocol Categories**: Basic protocols (Equatable, Comparable, Hashable), Copy protocols, Concurrency protocols (Sendable, Actor), Collection protocols
- **Implementation Patterns**: Value types vs reference types, protocol composition, generic constraints
- **Testing Strategy**: Each protocol concept has corresponding comprehensive tests demonstrating real-world usage

#### OpenAPIClientGenerator Target
Practical demonstration of Apple's Swift OpenAPI Generator:
- **Configuration-Driven**: Multiple YAML configs showing different generation options (`types`, `client`, `server`, access modifiers)
- **Build-Time Generation**: Uses Swift Package Manager plugins to generate code during build
- **Type Safety**: Demonstrates compile-time API contract enforcement through generated Swift types

### Key Dependencies and Integration Points

**Swift OpenAPI Generator Stack**:
- `swift-openapi-generator` - Build plugin for code generation
- `swift-openapi-runtime` - Runtime types and abstractions
- `swift-openapi-urlsession` - URLSession-based transport layer

**Generated Code Integration**:
- PetStoreClient.swift wraps generated Client with higher-level API
- Error handling bridges OpenAPI responses to custom Swift error types
- Demonstrates async/await patterns with generated async methods

### Configuration Files Impact

Different `openapi-generator-config.yaml` files produce different generated code:
- `generate: [types]` - Only data types, no HTTP implementation
- `generate: [types, client]` - Includes HTTP client methods
- `generate: [types, server]` - Includes server protocol definitions
- `accessModifier` - Controls public/internal/package visibility of generated code

### Testing Architecture

**Protocol Tests**: Focus on demonstrating protocol benefits and usage patterns rather than just correctness
**OpenAPI Tests**: Test the wrapper layer around generated code, not the generated code itself (which is tested upstream)

## Platform Support

Supports iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+ as defined in Package.swift platforms configuration.

## Development Workflow

1. Protocol examples follow: implement → test → document pattern
2. OpenAPI changes require: modify openapi.yaml → build (regenerates code) → update wrapper code if needed
3. Generated OpenAPI code should never be manually edited (regenerated on each build)
4. Configuration changes in YAML files affect what gets generated - see GenerationOptionsDocumentation.md for details