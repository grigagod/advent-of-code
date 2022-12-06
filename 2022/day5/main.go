package main

import (
	"container/heap"
	_ "embed"
	"flag"
	"fmt"
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

func main() {
	var part int
	flag.IntVar(&part, "p", 1, "puzzle to run")
	flag.Parse()
	fmt.Println("Running part", part)

	var out string
	switch part {
	case 2:
		out = second(input)
	default:
		out = first(input)
	}

	fmt.Println("Answer:", out)
}

type StringHeap []string

func (h StringHeap) Len() int           { return len(h) }
func (h StringHeap) Less(i, j int) bool { return len(h[i]) > len(h[j]) }
func (h StringHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *StringHeap) Push(x interface{}) {
	*h = append(*h, x.(string))
}

func (h *StringHeap) Pop() interface{} {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[0 : n-1]
	return x
}

type board struct {
	size int
	cols []*StringHeap
}

func initBoard(size int) *board {
	b := &board{
		size: size,
		cols: make([]*StringHeap, size),
	}
	for i := range b.cols {
		b.cols[i] = &StringHeap{}
		heap.Init(b.cols[i])
	}
	return b
}

func (h board) Push(val string, num int) {
	fmt.Printf("pushing %v, to %v\n", val, num)
	h.cols[num].Push(val)
}

func (h board) Pop(num int) string {
	return h.cols[num].Pop().(string)
}

type command struct {
	size int
	from int
	to   int
}

func mkCommand(s, f, t string) command {
	size, _ := strconv.Atoi(s)
	from, _ := strconv.Atoi(f)
	to, _ := strconv.Atoi(t)
	return command{size, from - 1, to - 1}
}

func (b *board) firstRow() string {
	row := ""
	for i := range b.cols {
		row += b.Pop(i)
	}
	return row
}

func pos(idx int) (out int) {
	if idx == 0 {
		return 1
	}
	return pos(idx-1) + 4
}

func first(in string) string {
	var delimeter, N int
	lines := strings.Split(in, "\n")
	var commands []command
	boardLines := []string{}
	for i, line := range lines {
		if line == "" {
			delimeter = i
			commands = make([]command, 0, len(lines)-i+1)
			continue
		}
		if delimeter == 0 {
			boardLines = append(boardLines, line)
		} else {
			runes := strings.Split(line, " ")
			commands = append(commands,
				mkCommand(runes[1], runes[3], runes[5]))
		}
	}

	N = len(strings.Split(boardLines[len(boardLines)-1], "  "))
	b := initBoard(N)
	for i := len(boardLines) - 2; i >= 0; i-- {
		for j := 0; j < N; j++ {
			if val := string(boardLines[i][pos(j)]); val != " " {
				b.Push(string(val), j)
			}
		}
	}
	for _, cmd := range commands {
		for i := 0; i < cmd.size; i++ {
			b.Push(b.Pop(cmd.from), cmd.to)
		}
	}

	return b.firstRow()
}

func second(in string) string {

	var delimeter, N int
	lines := strings.Split(in, "\n")
	var commands []command
	boardLines := []string{}
	for i, line := range lines {
		if line == "" {
			delimeter = i
			commands = make([]command, 0, len(lines)-i+1)
			continue
		}
		if delimeter == 0 {
			boardLines = append(boardLines, line)
		} else {
			runes := strings.Split(line, " ")
			commands = append(commands,
				mkCommand(runes[1], runes[3], runes[5]))
		}
	}

	N = len(strings.Split(boardLines[len(boardLines)-1], "  "))
	b := initBoard(N)
	for i := len(boardLines) - 2; i >= 0; i-- {
		for j := 0; j < N; j++ {
			if val := string(boardLines[i][pos(j)]); val != " " {
				b.Push(string(val), j)
			}
		}
	}
	for _, cmd := range commands {
		items := make([]string, cmd.size)
		for i := cmd.size - 1; i >= 0; i-- {
			items[i] = b.Pop(cmd.from)
		}
		for _, item := range items {
			b.Push(item, cmd.to)
		}
	}

	return b.firstRow()
}
