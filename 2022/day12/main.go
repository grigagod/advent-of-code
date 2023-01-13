package main

import (
	_ "embed"
	"flag"
	"fmt"
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
		out = second(input)
	default:
		out = first(input)
	}

	fmt.Println("Answer:", out)
}

var moves = [][2]int{
	{0, 1}, {1, 0}, {-1, 0}, {0, -1},
}

type Board struct {
	heights [][]int
}

func newBoard(input string) (start Cell, end Cell, b Board) {
	lines := strings.Split(input, "\n")
	b.heights = make([][]int, 0, len(lines))
	for i, line := range lines {
		cline := make([]int, len(line))
		for j := range line {
			if line[j] == 'S' {
				cline[j] = 0
				start = Cell{coord: [2]int{i, j}}
			} else if line[j] == 'E' {
				cline[j] = 25
				end = Cell{coord: [2]int{i, j}}
			} else {
				cline[j] = int(line[j] - 'a')
			}
		}
		b.heights = append(b.heights, cline)
	}
	return
}

func (b *Board) height() int {
	return len(b.heights)
}

func (b *Board) widght() int {
	return len(b.heights[0])
}

func (b *Board) upsideMoves(c Cell) []Cell {
	legal := make([]Cell, 0, len(moves))
	for _, d := range moves {
		x, y := c.coord[0]+d[0], c.coord[1]+d[1]
		if x < 0 || y < 0 || x >= b.height() || y >= b.widght() {
			continue
		}
		if canMove(b.heights[c.coord[0]][c.coord[1]], b.heights[x][y]) {
			legal = append(legal, Cell{coord: [2]int{x, y}, val: c.val + 1})
		}
	}
	return legal
}

func (b *Board) donwsideMoves(c Cell) []Cell {
	legal := make([]Cell, 0, len(moves))
	for _, d := range moves {
		x, y := c.coord[0]+d[0], c.coord[1]+d[1]
		if x < 0 || y < 0 || x >= b.height() || y >= b.widght() {
			continue
		}
		if canMove(b.heights[x][y], b.heights[c.coord[0]][c.coord[1]]) {
			legal = append(legal, Cell{coord: [2]int{x, y}, val: c.val + 1})
		}
	}
	return legal
}

type Cell struct {
	coord [2]int
	val   int
}

func canMove(curr, next int) bool {
	// moving down
	if curr > next {
		return true
	}
	// moving up
	return next-curr <= 1
}

func first(input string) int {
	seen := make(map[[2]int]bool)
	start, end, board := newBoard(input)

	queue := make(chan Cell, board.height()*board.widght())
	queue <- start
	for cell := range queue {
		if cell.coord == end.coord {
			return cell.val
		}
		if seen[cell.coord] {
			continue
		}
		seen[cell.coord] = true
		for _, next := range board.upsideMoves(cell) {
			queue <- next
		}
	}
	return 0
}

func second(input string) int {
	seen := make(map[[2]int]bool)
	_, end, board := newBoard(input)

	queue := make(chan Cell, board.height()*board.widght())
	queue <- end
	for cell := range queue {
		if board.heights[cell.coord[0]][cell.coord[1]] == 0 {
			return cell.val
		}
		if seen[cell.coord] {
			continue
		}
		seen[cell.coord] = true
		for _, next := range board.donwsideMoves(cell) {
			queue <- next
		}
	}
	return 0
}
