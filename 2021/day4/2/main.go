package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
	"strings"
)

const (
	lineN = 5
)

type Node struct {
	id  int
	val int
}

type Board struct {
	done     bool
	lines    [lineN]*Line
	cmatches [lineN]int // column matches
}

func (b *Board) Cbingo() bool {
	for _, v := range b.cmatches {
		if v == lineN {
			return true
		}
	}

	return false
}

type Line struct {
	board     *Board
	matched   map[int]bool
	positions map[int]int
	matchesN  int
}

func (l *Line) RBingo(num int) bool {
	id, ok := l.positions[num]
	if ok {
		if !l.matched[num] {
			l.matched[num] = true
			l.board.cmatches[id]++
			l.matchesN++
		}
		if l.matchesN == lineN {
			return true
		}
	}

	return false
}

func main() {
	file, err := os.Open("data/day4.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Scan()
	rules := strings.Split(scanner.Text(), ",")

	var boards []*Board
	var boardN int

	for scanner.Scan() {
		board := &Board{}
		for i := 0; i < lineN; i++ {
			scanner.Scan()

			line := &Line{
				board:     board,
				matched:   make(map[int]bool),
				positions: make(map[int]int),
			}

			row := strings.Fields(scanner.Text())

			for id, s := range row {
				num, err := strconv.Atoi(s)
				if err != nil {
					log.Fatal(err)
				}
				line.positions[num] = id
				line.matched[num] = false
			}

			board.lines[i] = line
		}

		boards = append(boards, board)
		boardN++
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	var doneBoards int
	var winBoard int
	var winN int

	for _, s := range rules {
		num, err := strconv.Atoi(s)
		if err != nil {
			log.Fatal(err)
		}

		for i, board := range boards {
			if board.done {
				continue
			}
		LINE:
			for _, line := range board.lines {
				if line.RBingo(num) {
					doneBoards++
					board.done = true
					winBoard = i
					winN = num
					break LINE
				}
			}

			if !board.done && board.Cbingo() {
				doneBoards++
				board.done = true
				winBoard = i
				winN = num
			}
		}

		if doneBoards == boardN {
			break
		}
	}

	var sum int

	log.Println(doneBoards)

	for _, line := range boards[winBoard].lines {
		for num, match := range line.matched {
			if !match {
				sum = sum + num
			}
		}

	}

	log.Println(sum * winN)

}
