#!/bin/bash

echo "===== Legato Build Diagnostic Script ====="
echo "Date: $(date)"
echo ""

echo "=== 1. Python Environment ==="
python3 --version
python3 -c "import jinja2; print('jinja2 OK')" 2>&1
python3 -c "import git; print('git OK')" 2>&1
echo ""

echo "=== 2. ifgen Script Check ==="
head -1 framework/tools/ifgen/ifgen
ifgen --version 2>&1 || echo "ifgen failed"
echo ""

echo "=== 3. Build Status ==="
if [ -d "build" ]; then
    echo "Build directory exists"
    ls -la build/ 2>&1 | head -20
else
    echo "No build directory found"
fi
echo ""

echo "=== 4. Attempt Build ==="
make clean 2>&1 | tail -5
make 2>&1 | tail -100
