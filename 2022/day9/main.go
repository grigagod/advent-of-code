package main

import (
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

	var out int
	switch part {
	case 2:
		out = puzzle(input, 9)
	default:
		out = puzzle(input, 1)
	}

	fmt.Println("Answer:", out)
}

type Position struct {
	x, y int
}

func (p Position) move(d Direction) Position {
	return Position{p.x + d.x, p.y + d.y}
}

func (a Position) near(b Position) bool {
	if dx := a.x - b.x; !(dx > -2 && dx < 2) {
		return false
	}
	if dy := a.y - b.y; !(dy > -2 && dy < 2) {
		return false
	}

	return true
}

type Direction Position

var directions = map[string]Direction{
	"L": {-1, 0},
	"R": {1, 0},
	"U": {0, 1},
	"D": {0, -1},
}

type Knot struct {
	id   int
	pos  Position
	prev *Knot
}

type Rope struct {
	head *Knot
	tail *Knot
}

func newRope(size int) *Rope {
	rope := &Rope{head: &Knot{}, tail: &Knot{id: size}}
	rope.head.prev = rope.tail
	for i := size - 1; i > 0; i-- {
		knot := &Knot{id: i, prev: rope.head.prev}
		rope.head = &Knot{prev: knot}
	}
	return rope
}

func (r *Rope) moveTail(head *Knot) Position {
	headPos := head.pos
	if head.prev == nil {
		return headPos
	}
	tail := head.prev
	if tail.pos.near(headPos) {
		return r.tail.pos
	}

	delta := Direction{headPos.x - tail.pos.x, headPos.y - tail.pos.y}
	dir := Direction{}
	if (delta.x*delta.x + delta.y*delta.y) > 2 {
		if delta.x != 0 {
			if delta.x > 0 {
				dir.x = 1
			} else {
				dir.x = -1
			}
		}
		if delta.y != 0 {
			if delta.y > 0 {
				dir.y = 1
			} else {
				dir.y = -1
			}
		}
	}
	tail.pos = tail.pos.move(dir)

	return r.moveTail(tail)
}

func puzzle(in string, size int) int {
	rope := newRope(size)
	tailPositions := make(map[Position]struct{})

	for _, line := range strings.Split(in, "\n") {
		fmt.Println(line)
		chars := strings.Split(line, " ")
		n, err := strconv.Atoi(chars[1])
		if err != nil {
			panic(err)
		}
		for i := 0; i < n; i++ {
			rope.head.pos = rope.head.pos.move(directions[chars[0]])
			tailPos := rope.moveTail(rope.head)
			tailPositions[tailPos] = struct{}{}
		}
	}
	return len(tailPositions)
}
