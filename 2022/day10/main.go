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

	switch part {
	case 2:
		fmt.Println(second(input, []int{40, 40, 40, 40, 40, 40}))
	default:
		fmt.Println(first(input, []int{20, 60, 100, 140, 180, 220}))
	}
}

func parseCommand(line string) (int, int) {
	chars := strings.Split(line, " ")
	if len(chars) == 1 {
		return 1, 0
	}
	valToAdd, err := strconv.Atoi(chars[1])
	if err != nil {
		panic(err)
	}
	return 2, valToAdd

}

func first(in string, interest []int) int {
	var cycle, totalStrength int
	regX := 1

	for _, line := range strings.Split(in, "\n") {
		if len(interest) == 0 {
			break
		}
		cyclesToSkip, valToAdd := parseCommand(line)
		for i := 0; i < cyclesToSkip; i++ {
			cycle++
			if cycle == interest[0] {
				totalStrength += cycle * regX
				interest = interest[1:]
			}
		}
		regX += valToAdd

	}
	return totalStrength
}

func second(in string, rowsSizes []int) string {
	var drawPos int
	currentDef := 0
	rowsToPrint := make([]string, len(rowsSizes))
	spritePos := 1

	for _, line := range strings.Split(in, "\n") {
		if currentDef == len(rowsSizes) {
			break
		}
		cyclesToSkip, valToAdd := parseCommand(line)
		for i := 0; i < cyclesToSkip; i++ {
			if drawPos == rowsSizes[currentDef] {
				currentDef++
				drawPos = 0
				if currentDef == len(rowsSizes) {
					return strings.Join(rowsToPrint, "\n")
				}
			}
			if delta := drawPos - spritePos; (delta >= 0 && delta < 2) || (delta < 0 && delta > -2) {
				rowsToPrint[currentDef] = rowsToPrint[currentDef] + "#"
			} else {
				rowsToPrint[currentDef] = rowsToPrint[currentDef] + "."
			}
			drawPos++
		}
		spritePos += valToAdd

	}

	return strings.Join(rowsToPrint, "\n")
}
