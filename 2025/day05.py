import sys

lines = sys.stdin.read().splitlines()

ranges = []

for i, line in enumerate(lines):
    if len(line) == 0:
        break
    parts = line.split('-')
    start, end = int(parts[0]), int(parts[1])
    ranges.append((start, end))

ranges = sorted(ranges, key=lambda rng: rng[0])

merged = set()

for i in range(0, len(ranges) - 1):
    s1, e1 = ranges[i][0], ranges[i][1]
    s2, e2 = ranges[i+1][0], ranges[i+1][1]
    if s2 <= e1:
        ranges[i+1] = (s1, max(e1, e2))
        merged.add(i)

ans = 0

for i, rng in enumerate(ranges):
    if i in merged:
        continue
    ans += (rng[1] - rng[0]) + 1

print(ans)
