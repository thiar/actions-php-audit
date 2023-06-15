package main

import (
	"errors"
	"fmt"
	"os"
	"strings"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Wrong number of arguments specified.")
		os.Exit(1)
	}
	message := os.Args[1]
	result := formatGithubMessage(message)
	if result == "" {
		fmt.Println("No security issues.")
	}
	if result != "" {
		fmt.Print(formatGithubMessage(message))
	}
}

func formatGithubMessage(message string) string {
	const title = "# PHP Security Check Report\\n=============================\\n"
	body, err := selectMessageBody(message)
	if err != nil {
		return ""
	}
	return title + body
}

func selectMessageBody(message string) (string, error) {
	start := strings.Index(message, "[CVE")
	if start == -1 {
		return "", errors.New("No error information.")
	}
	result := strings.Replace(strings.Replace(message[start:], "\n", "", -1), "[CVE", "\\n- [ ] [CVE", -1)
	return result, nil
}
