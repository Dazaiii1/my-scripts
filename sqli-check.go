package main

import (
        "net/http"
        "fmt"
        "time"
        "flag"
        "strings"
)

var (
        url string
        header string
)

func main() {
        flag.StringVar(&url, "u", "", "Target URL ")
        flag.StringVar(&header, "H", "", "Include Custom HTTP Custom Header in the request ")
        flag.Parse()

        if url != `` {
                sqli_checker()
        }
}

func sqli_checker(){

        start := time.Now()

        client := http.Client{
                //Timeout : 14 * time.Second,
        }

        req , err := http.NewRequest("GET", url, nil)
        if err != nil {
            fmt.Println(err)
        }

        if header != ``  {
                s := strings.SplitN(header, ":", 2)
                req.Header.Set(s[0], s[1]) 
        }

        _ ,err = client.Do(req)
        if err != nil {
            fmt.Println(err)
        }
        
        elapsed := time.Since(start).Seconds()

        fmt.Println(elapsed)

}
