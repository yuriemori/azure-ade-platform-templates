#!/bin/bash

# Azure Deployment Environments Catalog Validation Script
# This script validates the ADE catalog structure and templates

set -e

echo "🔍 Validating Azure Deployment Environments Catalog..."

# Check required tools
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is required but not installed."
    exit 1
fi

echo "✅ Azure CLI found"

# Navigate to catalog directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG_DIR="$SCRIPT_DIR"

echo "📁 Catalog directory: $CATALOG_DIR"

# Validate catalog structure
echo "🏗️  Validating catalog structure..."

if [ ! -d "$CATALOG_DIR/environment-definitions" ]; then
    echo "❌ Missing environment-definitions directory"
    exit 1
fi

echo "✅ environment-definitions directory found"

# Validate each environment definition
for env_dir in "$CATALOG_DIR/environment-definitions"/*; do
    if [ -d "$env_dir" ]; then
        env_name=$(basename "$env_dir")
        echo "🔧 Validating environment definition: $env_name"
        
        # Check required files
        if [ ! -f "$env_dir/manifest.yaml" ]; then
            echo "❌ Missing manifest.yaml in $env_name"
            exit 1
        fi
        echo "  ✅ manifest.yaml found"
        
        if [ ! -f "$env_dir/main.bicep" ]; then
            echo "❌ Missing main.bicep in $env_name"
            exit 1
        fi
        echo "  ✅ main.bicep found"
        
        if [ ! -f "$env_dir/README.md" ]; then
            echo "❌ Missing README.md in $env_name"
            exit 1
        fi
        echo "  ✅ README.md found"
        
        # Validate Bicep template
        echo "  🔍 Validating Bicep template..."
        if az bicep build --file "$env_dir/main.bicep" --stdout > /dev/null 2>&1; then
            echo "  ✅ Bicep template is valid"
        else
            echo "  ❌ Bicep template validation failed"
            az bicep build --file "$env_dir/main.bicep" --stdout
            exit 1
        fi
        
        # Validate manifest.yaml syntax
        echo "  🔍 Validating manifest.yaml..."
        if python3 -c "import yaml; yaml.safe_load(open('$env_dir/manifest.yaml'))" 2>/dev/null; then
            echo "  ✅ manifest.yaml is valid YAML"
        else
            echo "  ❌ manifest.yaml is not valid YAML"
            exit 1
        fi
        
        echo "  ✅ Environment definition $env_name is valid"
    fi
done

echo ""
echo "🎉 Catalog validation completed successfully!"
echo ""
echo "📋 Summary:"
echo "  - Catalog structure: ✅ Valid"
echo "  - Environment definitions: ✅ All valid"
echo "  - Bicep templates: ✅ All valid"
echo "  - Manifest files: ✅ All valid"
echo ""
echo "🚀 Your catalog is ready for deployment!"
echo ""
echo "Next steps:"
echo "1. Follow the setup guide in ADE-SETUP.md"
echo "2. Register this catalog in your Dev Center"
echo "3. Create environments using the Developer Portal"