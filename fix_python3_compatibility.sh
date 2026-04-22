#!/bin/bash

echo "===== Python 2 to 3 Compatibility Fixer ====="

# Files to fix
files=("framework/tools/ifgen/ifgen"
       "framework/tools/ifgen/ifgenJinjaExtensions.py"
       "framework/tools/ifgen/interfaceParser.py"
       "framework/tools/ifgen/interfaceLexer.py"
       "framework/tools/ifgen/langJava/codeGenHelpers.py"
       "framework/tools/ifgen/langC/codeGenHelpers.py"
       "framework/tools/ifgen/interface.g"
       "framework/tools/ifgen/antlr3/__init__.py"
       "framework/tools/ifgen/antlr3/dfa.py"
       "framework/tools/ifgen/antlr3/streams.py"
       "framework/tools/ifgen/antlr3/recognizers.py"
       "framework/tools/ifgen/antlr3/extras.py"
       "framework/tools/ifgen/antlr3/debug.py"
       "framework/tools/ifgen/antlr3/tree.py"
       "framework/tools/ifgen/antlr3/tokens.py"
       "framework/tools/ifgen/antlr3/exceptions.py")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Fixing $file..."
        
        # 1. Fix print statements
        sed -i 's/print\s\+\("[^"]*"\|\'\''[^'\'']*'\''\|\$.*\)/print(\1)/g' "$file"
        
        # 2. Fix exception handling syntax
        sed -i 's/except \([^,]*\), \([^:]*\):/except \1 as \2:/g' "$file"
        
        # 3. Fix relative imports in antlr3
        if [[ "$file" == *"antlr3"* ]]; then
            sed -i 's/from \([a-z0-9_]*\) import/from .\1 import/g' "$file"
        fi
        
        # 4. Fix StringIO import
        sed -i 's/from StringIO import StringIO/from io import StringIO/g' "$file"
        
        # 5. Fix division operator
        sed -i 's/\(range(.*\)\/\([^)]*\))/\1\/\/\2)/g' "$file"
        
        # 6. Fix xrange → range
        sed -i 's/xrange(/range(/g' "$file"
        
        # 7. Fix dict methods
        sed -i 's/iteritems()/items()/g' "$file"
        sed -i 's/itervalues()/values()/g' "$file"
        sed -i 's/iterkeys()/keys()/g' "$file"
        
        # 8. Fix dict.has_key() → 'key' in dict
        sed -i 's/\(.*\)\.has_key(\(.*\))/\2 in \1/g' "$file"
        
        echo "Fixed $file"
    else
        echo "File $file not found"
    fi
done

echo ""
echo "===== Fix Complete ====="
echo "All files have been updated for Python 3 compatibility."
echo ""
echo "Now running ifgen test..."

# Test ifgen
ifgen --version 2>&1 || echo "ifgen test failed"

echo ""
echo "===== Test Complete ====="
