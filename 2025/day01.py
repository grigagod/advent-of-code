import sys

n = 100
value = 50
pwd = 0

for line in map(str.rstrip, sys.stdin):
    dir, num = line[0], int(line[1:])
    if dir == 'R':
        value += num
    else:
        value -= num

    while value < 0:
        if value + num != 0:
            pwd += 1
        value += n
    while value > n:
        value -= n
        pwd += 1

    value = value % n

    if value == 0:
        pwd += 1

print(pwd)
