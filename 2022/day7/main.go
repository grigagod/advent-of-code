package main

import (
	_ "embed"
	"flag"
	"fmt"
	"log"
	"sort"
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

	var out int
	switch part {
	case 2:
		out = second(input, 70000000, 30000000)
	default:
		out = first(input, 100000)
	}

	fmt.Println("Answer:", out)
}

var root *dir = newDir("/", nil)

type file struct {
	name string
	size int
}

type dir struct {
	name   string
	parent *dir
	size   int

	files map[string]file
	dirs  map[string]*dir
}

func newDir(name string, parent *dir) *dir {
	return &dir{
		name:   name,
		parent: parent,
		files:  map[string]file{},
		dirs:   map[string]*dir{},
	}
}

func (d *dir) ls() ([]*dir, []file) {
	if d == nil {
		return nil, nil
	}
	files := make([]file, 0, len(d.files))
	for _, f := range d.files {
		files = append(files, f)
	}
	dirs := make([]*dir, 0, len(d.dirs))
	for _, d := range d.dirs {
		dirs = append(dirs, d)
	}
	return dirs, files
}

func (d *dir) cd(name string) *dir {
	if d == nil {
		return nil
	}
	switch name {
	case "/":
		return root
	case "..":
		return d.parent
	}
	d, ok := d.dirs[name]
	if !ok {
		log.Fatalf("dir '%s' is not found inside '%s'", name, d.name)
	}
	return d
}

func (d *dir) addDir(child *dir) {
	if d == nil || child == nil {
		return
	}
	d.dirs[child.name] = child
}

func (d *dir) addFile(child file) {
	if d == nil {
		return
	}
	d.files[child.name] = child
	d.size += child.size
	// propagate size update to all parents
	parent := d.parent
	for parent != nil {
		parent.size += child.size
		parent = parent.parent
	}
}

func buildFileTree(in string) {
	lines := strings.Split(in, "\n")
	curentDir := root
	for _, line := range lines {
		words := strings.Split(line, " ")
		switch words[0] {
		case "$":
			switch words[1] {
			case "cd":
				curentDir = curentDir.cd(words[2])
			}
		case "dir":
			curentDir.addDir(newDir(words[1], curentDir))
		default:
			size, err := strconv.Atoi(words[0])
			if err != nil {
				log.Fatal(err)
			}
			curentDir.addFile(file{name: words[1], size: size})
		}
	}
}

func dirSizesUnderCond(d *dir, cond func(size int) bool) []int {
	dirs, _ := d.ls()
	sizes := make([]int, 0, len(dirs))
	for _, d := range dirs {
		if cond(d.size) {
			sizes = append(sizes, d.size)
		}
		sizes = append(sizes, dirSizesUnderCond(d, cond)...)
	}
	return sizes
}

func first(in string, limit int) int {
	buildFileTree(in)
	var sum int
	for _, size := range dirSizesUnderCond(root, func(size int) bool { return size < limit }) {
		sum += size
	}
	return sum
}

func second(in string, available, goal int) int {
	buildFileTree(in)
	minFree := goal - (available - root.size)
	fmt.Println("need to free: ", minFree)
	fmt.Println("root size: ", root.size)

	candidates := dirSizesUnderCond(root, func(size int) bool { return size >= minFree })
	if len(candidates) == 0 {
		log.Fatal("no candidates")
	}
	sort.Ints(candidates)
	return candidates[0]
}
