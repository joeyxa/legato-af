#!/bin/bash

echo "===== Python 2 to 3 Exception Syntax Fixer ====="

# Files to fix
files=("framework/tools/ifgen/interfaceParser.py"
       "framework/tools/ifgen/langJava/codeGenHelpers.py"
       "framework/tools/ifgen/interface.g"
       "framework/tools/ifgen/antlr3/extras.py"
       "framework/tools/ifgen/antlr3/recognizers.py")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Fixing $file..."
        # Replace Python 2 exception syntax with Python 3
        sed -i 's/except \([^,]*\), \([^:]*\):/except \1 as \2:/g' "$file"
        echo "Fixed $file"
    else
        echo "File $file not found"
    fi
done

echo ""
echo "===== Fix Complete ====="
echo "All files have been updated to use Python 3 exception syntax."
