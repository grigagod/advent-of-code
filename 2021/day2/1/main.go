package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
	"strings"
)

type Position struct {
	x int
	y int
}

func (p *Position) Move(key string, delta int) {
	switch key {
	case "forward":
		p.x = p.x + delta
	case "up":
		p.y = p.y - delta
	case "down":
		p.y = p.y + delta
	}
}

func (p *Position) Mul() int {
	return p.x * p.y
}

func main() {
	file, err := os.Open("data/day2.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var pos Position

	for scanner.Scan() {

		row := strings.Split(scanner.Text(), " ")
		if len(row) != 2 {
			log.Fatal("wrong input")
		}

		delta, err := strconv.Atoi(row[1])
		if err != nil {
			log.Fatal(err)
		}

		pos.Move(row[0], delta)
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	log.Print(pos.Mul())
}
