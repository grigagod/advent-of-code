package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
)

func main() {
	file, err := os.Open("data/day1.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var prev, ans int

	for scanner.Scan() {
		next, err := strconv.Atoi(scanner.Text())
		if err != nil {
			log.Fatal(err)
		}

		if next > prev {
			ans++
		}

		prev = next
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	log.Print(ans - 1)
}
