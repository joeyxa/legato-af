#!/bin/bash

echo "===== Legato Build and Debug Script ====="
echo "Date: $(date)"
echo ""

echo "=== 1. Environment Check ==="
python3 --version
python3 -c "import jinja2; print('jinja2 OK')" 2>&1
python3 -c "import git; print('git OK')" 2>&1
echo ""

echo "=== 2. ifgen Test ==="
ifgen --version 2>&1 || echo "ifgen test failed"
echo ""

echo "=== 3. Build Legato Framework ==="
echo "Starting build..."
make 2>&1 | tee build.log

echo ""
echo "=== 4. Build Summary ==="
if grep -q "Error" build.log; then
    echo "Build failed. Last 50 lines of output:"
    tail -50 build.log
else
    echo "Build successful!"
    ls -la build/localhost/framework/bin/
fi

echo ""
echo "=== 5. Toolchain Check ==="
ls -la bin/

echo ""
echo "===== Script Complete ====="
