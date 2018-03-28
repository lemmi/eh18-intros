package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
)

func compareFile(path string, content []byte) bool {
	fi, err := os.Stat(path)
	if err != nil {
		return false
	}
	if fi.Size() != int64(len(content)) {
		return false
	}

	buff, err := ioutil.ReadFile(path)
	if err != nil {
		return false
	}
	return bytes.Compare(buff, content) == 0
}

func replaceIfNewer(path string, content []byte) error {
	if compareFile(path, content) {
		return nil
	}
	return ioutil.WriteFile(path, content, 0664)
}

func main() {
	dir := "./"
	if len(os.Args) == 2 {
		dir = os.Args[1]
	}

	var eh18 EH18
	if err := json.NewDecoder(os.Stdin).Decode(&eh18); err != nil {
		log.Fatal(err)
	}

	for _, day := range eh18.Schedule.Conference.Days {
		for _, talks := range day.Rooms {
			for _, talk := range talks {
				if talk.DoNotRecord {
					continue
				}
				filename := fmt.Sprint(talk.ID) + ".json"
				path := filepath.Join(dir, filename)

				var buf []byte
				buf, err := json.MarshalIndent(talk, "", "\t")
				if err != nil {
					log.Fatal(err)
				}

				if err := replaceIfNewer(path, buf); err != nil {
					log.Fatal(err)
				}

				fmt.Println(talk.ID, talk.Title)
			}
		}
	}
}
