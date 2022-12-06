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

	var out int32
	switch part {
	case 2:
		out = second(input)
	default:
		out = first(input)
	}

	fmt.Println("Answer:", out)
}

func split(s []string) (int, int) {
	s1, _ := strconv.Atoi(s[0])
	s2, _ := strconv.Atoi(s[1])
	return s1, s2
}

func contain(a1, b1, a2, b2 int) bool {
	if a1 <= a2 && b1 >= b2 {
		return true
	}
	return false
}

func overlap(a1, b1, a2, b2 int) bool {
	if a1 < a2 {
		if b1 >= a2 {
			return true
		}
	} else if b2 >= a1 {
		return true
	}
	return false
}

func first(in string) int32 {
	lines := strings.Split(in, "\n")
	var total int32
	for _, line := range lines {
		pairs := strings.Split(line, ",")
		seg1pts := strings.Split(pairs[0], "-")
		seg2pts := strings.Split(pairs[1], "-")
		a1, b1 := split(seg1pts)
		a2, b2 := split(seg2pts)
		if contain(a1, b1, a2, b2) || contain(a2, b2, a1, b1) {
			fmt.Println(line, a1, b1, a2, b2)
			total++
		}

	}
	return total
}

func second(in string) int32 {
	lines := strings.Split(in, "\n")
	var total int32
	for _, line := range lines {
		pairs := strings.Split(line, ",")
		seg1pts := strings.Split(pairs[0], "-")
		seg2pts := strings.Split(pairs[1], "-")
		a1, b1 := split(seg1pts)
		a2, b2 := split(seg2pts)
		if overlap(a1, b1, a2, b2) || contain(a2, b2, a1, b1) {
			fmt.Println(line, a1, b1, a2, b2)
			total++
		}

	}
	return total
}
