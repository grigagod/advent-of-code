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
		out = puzzle(input, 14)
	default:
		out = puzzle(input, 4)
	}

	fmt.Println("Answer:", out)
}

type Buffer[T comparable] interface {
	Write(entry T)
	Read() T
	Entries() []T
}

type buffer[T comparable] struct {
	head, tail int
	len        int
	entries    []T
}

func (b *buffer[T]) Entries() (entrs []T) {
	if b == nil {
		return entrs
	}
	var zero T
	entrs = make([]T, 0, cap(b.entries))

	for _, entry := range b.entries {
		if entry != zero {
			entrs = append(entrs, entry)
		}
	}
	return entrs
}

func (b *buffer[T]) Write(entry T) {
	if b == nil {
		return
	}
	if b.len != cap(b.entries) {
		b.entries[b.tail] = entry
		b.tail = (b.tail + 1) % len(b.entries)
		b.len++
		return
	}
	b.entries[b.head] = entry
	b.head = (b.head + 1) % len(b.entries)
}

func (b *buffer[T]) Read() (entry T) {
	if b == nil || len(b.entries) == 0 {
		return
	}
	entry = b.entries[b.head]
	b.head = (b.head + 1) % len(b.entries)
	b.len--
	return
}

func NewBuffer[T comparable](cap int) Buffer[T] {
	return &buffer[T]{
		entries: make([]T, cap),
	}
}

func puzzle(in string, n int) int {
	buf := NewBuffer[string](n)
	for i, code := range in {
		buf.Write(string(code))
		uniqueEntries := map[string]struct{}{}
		for _, entry := range buf.Entries() {
			if _, ok := uniqueEntries[entry]; ok {
				break
			}
			uniqueEntries[entry] = struct{}{}
		}
		if len(uniqueEntries) == n {
			return i + 1
		}
	}

	return 0
}
