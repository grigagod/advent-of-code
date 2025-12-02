
sum = 0

def hasSequence(i):
    s = str(i)
    digits = len(s)
    for k in range(1, (digits // 2) +1):
        if digits % k != 0:
            continue
        seqs = [s[i:i+k] for i in range(0, digits, k)]
        if len(seqs)>1 and len(set(seqs)) == 1:
            return True
    return False

for rng in input().split(','):
    parts = rng.split('-')
    for i in range(int(parts[0]), int(parts[1])+1):
        if hasSequence(i):
            sum += i


print(sum)
