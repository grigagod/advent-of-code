import sys

grid = []
rolls = set()

for i, line in enumerate(map(str.rstrip, sys.stdin)):
    row = []
    for j, rune in enumerate(line):
        val = 0
        if rune == "@":
            val = 1
            rolls.add((i, j))
        row.append(val)
    grid.append(row)


def adjacent(pos, n):
    adj = []
    i, j = pos[0], pos[1]
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            adj.append((i + dx, j + dy))

    adj = [(x, y) for x, y in adj if x >= 0 and x < n and y >= 0 and y < n and not (x == i and y == j)]
    return adj

ans = 0

while True:
    toremove = []
    for roll in rolls:
        adj = adjacent(roll, len(grid))
        if sum(grid[i][j] for i, j in adj) < 4:
            toremove.append(roll)
            ans +=1
    if len(toremove) == 0:
        break
    for i, j in toremove:
        grid[i][j] = 0
        rolls.remove((i, j))

print(ans)
