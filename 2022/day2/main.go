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

type Shape int

const (
	Unknown Shape = iota
	Rock
	Paper
	Scissors
)

type Rule struct {
	Defeats Shape
	Loose   Shape
}

var (
	opponentShape = map[string]Shape{"A": Rock, "B": Paper, "C": Scissors}
	myNormalShape = map[string]Shape{"X": Rock, "Y": Paper, "Z": Scissors}

	RSP = map[Shape]Rule{
		// shape -> defeats, loose
		Rock:     {Scissors, Paper},
		Scissors: {Paper, Rock},
		Paper:    {Rock, Scissors},
	}
)

func first(in string) int {
	var myScore int
	for _, line := range strings.Split(in, "\n") {
		codes := strings.Split(line, " ")
		opShape, myShape := opponentShape[codes[0]], myNormalShape[codes[1]]
		switch {
		case opShape == myShape:
			myScore += 3
		case RSP[myShape].Defeats == opShape:
			{
				myScore += 6
			}
		}
		myScore += int(myShape)
	}
	return myScore
}

var myWierdBehaviour = map[string]func(Shape) Shape{
	"X": func(op Shape) Shape { return RSP[op].Defeats },
	"Y": func(op Shape) Shape { return op },
	"Z": func(op Shape) Shape { return RSP[op].Loose },
}

func second(in string) int {
	var myScore int
	for _, line := range strings.Split(in, "\n") {
		codes := strings.Split(line, " ")
		opShape := opponentShape[codes[0]]
		myShape := myWierdBehaviour[codes[1]](opShape)
		switch {
		case opShape == myShape:
			myScore += 3
		case RSP[myShape].Defeats == opShape:
			{
				myScore += 6
			}
		}
		myScore += int(myShape)
	}
	return myScore
}
