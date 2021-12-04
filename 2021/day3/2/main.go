package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
)

func selection(slice []string, ids []int) []string {
	out := make([]string, 0, len(ids))

	for _, id := range ids {
		out = append(out, slice[id])
	}

	return out
}

func main() {
	file, err := os.Open("data/day3.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var total int
	var values []string
	var zeroes, ones [12][]int

	for scanner.Scan() {
		row := scanner.Text()

		values = append(values, row)
		for i, c := range row {
			if c == '1' {
				ones[i] = append(ones[i], total)
			} else {
				zeroes[i] = append(zeroes[i], total)
			}
		}

		total++
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	gammas := values
	epsilons := values

	for i := 0; i < len(gammas[0]) && len(gammas) > 1; i++ {
		var sum int
		var zeroes, ones []int
		for j := 0; j < len(gammas); j++ {
			if gammas[j][i] == '1' {
				sum++
				ones = append(ones, j)
			} else {
				sum--
				zeroes = append(zeroes, j)
			}
		}

		if sum < 0 {
			gammas = selection(gammas, zeroes)
		} else {
			gammas = selection(gammas, ones)
		}
	}

	gamma, err := strconv.ParseInt(gammas[0], 2, 64)
	if err != nil {
		log.Fatal(err)
	}

	for i := 0; i < len(epsilons[0]) && len(epsilons) > 1; i++ {
		var sum int
		var zeroes, ones []int
		for j := 0; j < len(epsilons); j++ {
			if epsilons[j][i] == '1' {
				sum++
				ones = append(ones, j)
			} else {
				sum--
				zeroes = append(zeroes, j)
			}
		}

		if sum < 0 {
			epsilons = selection(epsilons, ones)
		} else {
			epsilons = selection(epsilons, zeroes)
		}
	}

	epsilon, err := strconv.ParseInt(epsilons[0], 2, 64)
	if err != nil {
		log.Fatal(err)
	}

	log.Print(gamma * epsilon)

}
