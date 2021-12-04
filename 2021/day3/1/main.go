package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	file, err := os.Open("data/day3.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var sums [12]int
	var total int
	var g, e string
	for scanner.Scan() {
		row := strings.Split(scanner.Text(), "")
		if len(row) != 12 {
			log.Fatal("wrong input")
		}

		for i, c := range row {
			if c == "1" {
				sums[i]++
			}
		}
		total++
	}

	total = total / 2

	for _, v := range sums {
		if v >= total {
			g = g + "1"
			e = e + "0"
		} else {
			g = g + "0"
			e = e + "1"
		}
	}

	epsilon, err := strconv.ParseInt(e, 2, 64)
	if err != nil {
		log.Fatal(err)
	}

	gamma, err := strconv.ParseInt(g, 2, 64)
	if err != nil {
		log.Fatal(err)
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	log.Print(gamma * epsilon)

}
