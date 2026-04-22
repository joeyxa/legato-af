import re

# 读取文件
with open('framework/tools/scripts/update-util', 'r') as f:
    content = f.read()

# 修复 print 'xxx' % (var) 的格式
content = re.sub(r"print '([^']+)' % \(([^)]+)\)", r"print('\1' % (\2))", content)

# 写入文件
with open('framework/tools/scripts/update-util', 'w') as f:
    f.write(content)

print('修复完成!')
