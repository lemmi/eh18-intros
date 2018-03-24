package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
)

func wrap(text string, width int) string {
	var buf strings.Builder

	l := 0
	sep := ""
	for _, word := range strings.Fields(text) {
		if l != 0 && l+len(word) > width {
			sep = "\n"
			l = 0
		}
		buf.WriteString(sep + word)
		sep = " "
		l += len(word)
	}

	return buf.String()
}

func main() {
	var err error

	infile := os.Stdin
	outfile := os.Stdout

	if len(os.Args) > 1 {
		infile, err = os.Open(os.Args[1])
		if err != nil {
			log.Fatal(err)
		}
		defer infile.Close()
	}
	if len(os.Args) > 2 {
		outfile, err = os.Create(os.Args[2])
		if err != nil {
			log.Fatal(err)
		}
		defer outfile.Close()
	}

	var talk Room
	if err := json.NewDecoder(infile).Decode(&talk); err != nil {
		log.Fatal(err)
	}

	title := wrap(talk.Title, 40)
	fmt.Fprintf(outfile, "%s\n\n", title)
	for _, p := range talk.Persons {
		fmt.Fprintf(outfile, "%s\n", p.Name)
	}
}
