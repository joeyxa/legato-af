#!/bin/bash

echo "===== Legato Build Status Check ====="
echo "Date: $(date)"
echo ""

echo "=== 1. ifgen Test ==="
ifgen --version 2>&1 || echo "ifgen failed"
echo ""

echo "=== 2. Build Progress ==="
if [ -d "build" ]; then
    echo "Build directory exists"
    find build -name "*.c" | head -10
    find build -name "*.h" | head -10
    echo ""
    echo "=== 3. Last Build Output ==="
    ls -la build/ 2>&1 | head -20
else
    echo "No build directory found"
fi

echo ""
echo "=== 4. Attempt Build (last 50 lines) ==="
make 2>&1 | tail -50
