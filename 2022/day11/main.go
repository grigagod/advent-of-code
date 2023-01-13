package main

import (
	_ "embed"
	"flag"
	"fmt"
	"math/big"
	"sort"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func init() {
	input = strings.TrimRight(input, "\n")
	if len(input) == 0 {
		panic("empty input.txt file")
	}
}

var lcf *big.Int
var divs []*big.Int

func main() {
	var part int
	flag.IntVar(&part, "p", 1, "puzzle to run")
	flag.Parse()
	fmt.Println("Running part", part)

	var out uint64
	switch part {
	case 2:
		out = puzzle(input, 10000, false)
	default:
		lcf = big.NewInt(1)
		out = puzzle(input, 20, true)
	}

	fmt.Println("Answer:", out)
}

type throwBucket struct {
	id    int
	items []*big.Int
}

type action func(*big.Int) (int, *big.Int)

type itemOp func(*big.Int) *big.Int

type monkey struct {
	id           int
	items        []*big.Int
	itemOp       itemOp
	throwRules   [][2]int
	action       action
	inspectCount uint64
}

func (m *monkey) addItems(itms []*big.Int) {
	m.items = append(m.items, itms...)
}

func (m *monkey) reset() {
	m.items = []*big.Int{}
	m.throwRules[0][1] = 0
	m.throwRules[1][1] = 0
}

func (m *monkey) inspect() []throwBucket {
	if len(m.items) == 0 {
		return nil
	}
	out := make([]throwBucket, 0, 2)
	throwMap := make(map[int][]*big.Int, len(m.items))
	for _, tuple := range m.throwRules {
		throwMap[tuple[0]] = make([]*big.Int, 0, tuple[1])
	}
	for _, item := range m.items {
		id, itm := m.action(m.itemOp(item))
		throwMap[id] = append(throwMap[id], itm)
		m.inspectCount++
	}
	for id, items := range throwMap {
		out = append(out, throwBucket{id: id, items: items})
	}
	m.reset()

	return out
}

func afterPrefix(str, prefix string) string {
	return strings.TrimPrefix(strings.TrimSpace(str), prefix)
}
func mustAtoi(str string) int {
	out, err := strconv.Atoi(str)
	if err != nil {
		panic(err)
	}
	return out
}

func mustBigInt(str string) *big.Int {
	out := &big.Int{}
	out, ok := out.SetString(str, 10)
	if !ok {
		panic("failed to set string")
	}
	return out
}

func parseVal(char string, i *big.Int) *big.Int {
	if char == "old" {
		return i
	}
	return mustBigInt(char)
}

func parseOp(char string) func(a, b *big.Int) *big.Int {
	if char == "+" {
		return func(a, b *big.Int) *big.Int { return a.Add(a, b) }
	}
	return func(a, b *big.Int) *big.Int { return a.Mul(a, b) }
}

func newItemOp(chars []string, worried bool) itemOp {
	if worried {
		return func(i *big.Int) *big.Int {
			out := &big.Int{}
			return out.Div(parseOp(chars[1])(parseVal(chars[0], i), parseVal(chars[2], i)), big.NewInt(3))
		}
	}
	return func(i *big.Int) *big.Int {
		return parseOp(chars[1])(parseVal(chars[0], i), parseVal(chars[2], i))
	}
}

func newMonkey(id int, lines []string, worried bool) *monkey {
	m := &monkey{id: id}
	sitems := strings.Split(afterPrefix(lines[0], "Starting items: "), ", ")
	m.items = make([]*big.Int, 0, len(sitems))
	for _, sitem := range sitems {
		m.items = append(m.items, mustBigInt(sitem))
	}
	m.itemOp = newItemOp(strings.Split(afterPrefix(lines[1], "Operation: new = "), " "), worried)

	divBy := mustBigInt(afterPrefix(lines[2], "Test: divisible by "))
	divs = append(divs, divBy)
	okThrowID := mustAtoi(afterPrefix(lines[3], "If true: throw to monkey "))
	failThrowID := mustAtoi(afterPrefix(lines[4], "If false: throw to monkey "))
	m.throwRules = [][2]int{{okThrowID, 0}, {failThrowID, 0}}
	m.action = func(i *big.Int) (int, *big.Int) {
		rem := &big.Int{}
		i.Mod(i, lcf)
		rem.Rem(i, divBy)
		if rem.Cmp(big.NewInt(0)) == 0 {
			m.throwRules[0][1]++
			return okThrowID, i
		}
		m.throwRules[1][1]++
		return failThrowID, i
	}
	return m
}

func puzzle(in string, roundsN int, worried bool) uint64 {
	lines := strings.Split(in, "\n")
	monkeys := make([]*monkey, 0, len(lines)/7)
	divs = make([]*big.Int, 0, len(monkeys))
	for i := 1; i < len(lines); i += 7 {
		monkeys = append(monkeys, newMonkey(len(monkeys), lines[i:i+5], worried))
	}
	if !worried {
		gcd := big.NewInt(divs[0].Int64())
		lcf = big.NewInt(divs[0].Int64())
		for _, div := range divs[1:] {
			gcd = gcd.GCD(nil, nil, gcd, div)
			lcf = lcf.Div(lcf.Mul(lcf, div), gcd)

		}
	}
	fmt.Println("Least commond divisor:", lcf.String())
	for i := 0; i < roundsN; i++ {
		for _, monk := range monkeys {
			for _, throw := range monk.inspect() {
				monkeys[throw.id].addItems(throw.items)
			}
		}
	}

	sort.SliceStable(monkeys, func(i, j int) bool {
		return monkeys[i].inspectCount > monkeys[j].inspectCount
	})
	var business uint64 = 1
	for _, monk := range monkeys[:2] {
		business *= monk.inspectCount
	}
	return business
}
