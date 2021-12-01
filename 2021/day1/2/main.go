package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
)

type Queue struct {
	data [3]int
}

func (q *Queue) Append(val int) {
	q.data[2] = q.data[1]
	q.data[1] = q.data[0]
	q.data[0] = val
}

func (q *Queue) Sum() int {
	var sum int
	for _, v := range q.data {
		sum = sum + v
	}
	return sum
}

func main() {
	file, err := os.Open("data/day1.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var prev, ans int
	var queue Queue

	for scanner.Scan() {
		val, err := strconv.Atoi(scanner.Text())
		if err != nil {
			log.Fatal(err)
		}

		queue.Append(val)
		next := queue.Sum()

		if next > prev {
			ans++
		}

		prev = next

	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	log.Print(ans - 3)
}
