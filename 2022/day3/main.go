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

	var out int32
	switch part {
	case 2:
		out = second(input)
	default:
		out = first(input)
	}

	fmt.Println("Answer:", out)
}

func priority(ch rune) rune {
	if ch < rune('a') {
		return ch - rune('A') + 27
	}
	return ch - rune('a') + 1
}

func totalPriority(items []rune) (total int32) {
	for _, item := range items {
		total += priority(item)
	}
	return
}

func sharedItems(first, second string) []rune {
	uniq := map[rune]struct{}{}
	for _, char := range second {
		if _, ok := uniq[char]; !ok && strings.ContainsRune(first, char) {
			uniq[char] = struct{}{}
		}
	}
	shared := make([]rune, 0, len(uniq))
	for item := range uniq {
		shared = append(shared, item)
	}
	return shared

}

func first(in string) int32 {
	lines := strings.Split(in, "\n")
	sharedItems := make([]rune, 0, len(lines))
	for _, line := range lines {
		firstHalf, secondHalf := line[:len(line)/2], line[len(line)/2:]
		for _, char := range firstHalf {
			if strings.ContainsRune(secondHalf, char) {
				sharedItems = append(sharedItems, char)
				break
			}

		}
	}
	return totalPriority(sharedItems)
}

func second(in string) rune {
	lines := strings.Split(in, "\n")
	shared := make([]rune, 0, len(lines)-2)
	for i := 0; i < len(lines); i += 3 {
		prev := sharedItems(lines[i], lines[i+1])
		shared = append(shared, sharedItems(string(prev), lines[i+2])...)
		fmt.Println("new shared items", shared)
	}
	return totalPriority(shared)
}
