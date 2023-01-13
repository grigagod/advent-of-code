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
	fmt.Println(len(input))
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

// line of trees -> [indexes of visible trees]
func visibleInlineTrees(line string) []int {
	idxs := []int{0, len(line) - 1}
	maxLeft, maxRight := rune(line[0]), rune(line[len(line)-1])
	maxLeftPos := 0
	for i := 1; i < len(line)-1; i++ {
		if rune(line[i]) > maxLeft {
			maxLeft = rune(line[i])
			maxLeftPos = i
			idxs = append(idxs, i)
		}
	}
	for j := len(line) - 2; j > maxLeftPos; j-- {
		if rune(line[j]) > rune(maxRight) {
			maxRight = rune(line[j])
			idxs = append(idxs, j)
		}
	}
	return idxs
}

func first(in string) int {
	var visibleTrees = make(map[[2]int]struct{})
	rows := strings.Split(in, "\n")
	gridSize := len(rows)
	columns := make([]string, gridSize)
	for i, row := range rows {
		for _, idx := range visibleInlineTrees(row) {
			visibleTrees[[2]int{i, idx}] = struct{}{}
		}

		for j := 0; j < gridSize; j++ {
			columns[j] = strings.Join([]string{columns[j], strconv.Itoa(int(rune(rows[i][j]) - 48))}, "")
		}
	}

	for j := 0; j < gridSize; j++ {
		for _, idx := range visibleInlineTrees(columns[j]) {
			visibleTrees[[2]int{idx, j}] = struct{}{}
		}
	}

	return len(visibleTrees)
}

func scenicScoreInline(line string) []int {
	right := make([]int, len(line))
	left := make([]int, len(line))
	for i := 0; i < len(line)-1; i++ {
		for j := i + 1; j < len(line); j++ {
			right[i] = right[i] + 1
			if line[i] <= line[j] {
				break
			}
		}
	}
	for i := len(line) - 1; i > 0; i-- {
		for j := i - 1; j >= 0; j-- {
			left[i] = left[i] + 1
			if line[i] <= line[j] {
				break
			}
		}
	}

	scores := make([]int, 0, len(line))
	for i := 0; i < len(line); i++ {
		scores = append(scores, right[i]*left[i])
	}
	return scores
}

func second(in string) int {
	rows := strings.Split(in, "\n")
	gridSize := len(rows)
	var scenicScores = make(map[[2]int]int, len(rows)*len(rows))
	columns := make([]string, gridSize)

	for i, row := range rows {
		for j, score := range scenicScoreInline(row) {
			scenicScores[[2]int{i, j}] = score
		}
		for j := 0; j < gridSize; j++ {
			columns[j] = strings.Join([]string{columns[j], strconv.Itoa(int(rune(rows[i][j]) - 48))}, "")
		}
		fmt.Println()
	}
	for j := 0; j < gridSize; j++ {
		for i, score := range scenicScoreInline(columns[j]) {
			scenicScores[[2]int{i, j}] = scenicScores[[2]int{i, j}] * score
		}
	}

	var max int
	for _, score := range scenicScores {
		if score > max {
			max = score
		}
	}
	return max
}
