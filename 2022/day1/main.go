package main

import (
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"
)

var puzzle int

func main() {
	flag.IntVar(&puzzle, "p", 1, "puzzle to run")
	flag.Parse()
	fmt.Println("Running puzzle", puzzle)
	bytes, err := os.ReadFile("./day1/input.txt")
	if err != nil {
		panic(err)
	}

	input := strings.TrimRight(string(bytes), "\n")

	var out int
	switch puzzle {
	case 2:
		out = second(input)
	default:
		out = first(input)
	}

	fmt.Println("Answer:", out)
}

func first(in string) int {
	var max, acc int
	for _, line := range strings.Split(in, "\n") {
		if line == "" {
			if acc > max {
				max = acc
			}
			acc = 0
			continue
		}
		cal, err := strconv.Atoi(line)
		if err != nil {
			panic(err)
		}
		acc += cal
	}
	return max
}

func second(in string) int {
	top3 := [3]int{} // in ascending order
	var acc int
	for _, line := range strings.Split(in, "\n") {
		if line == "" {
			fmt.Println("top:", top3)
			fmt.Println("acc:", acc)
			switch {
			case acc > top3[1]:
				if acc > top3[2] {
					top3 = [3]int{top3[1], top3[2], acc}
					break
				}
				top3 = [3]int{top3[1], acc, top3[2]}
			case acc > top3[0]:
				top3[0] = acc
			}
			acc = 0
			continue
		}

		cal, err := strconv.Atoi(line)
		if err != nil {
			panic(err)
		}
		acc += cal
	}

	var sum int
	for _, top := range top3 {
		sum += top
	}
	return sum
}
