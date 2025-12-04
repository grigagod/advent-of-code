import sys

def findMin(line, start, stop):
    ans, idx = 0, 0
    for i in range(start, stop):
        v = int(line[i])
        if v > ans:
            ans, idx = v, i
    return ans, idx

sum = 0
for line in map(str.rstrip, sys.stdin):
    start, digits, digitsN = 0, [], 12
    while digitsN > 0:
        digit, idx = findMin(line, start, len(line) - digitsN + 1)
        start = idx + 1
        digitsN -= 1
        digits.append(digit)

    sum += int("".join(map(str, digits)))

print(sum)
