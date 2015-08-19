package main

import (
	"encoding/json"
	"fmt"
	simplejson "github.com/bitly/go-simplejson"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

var Location = []byte(`
{
  "SHA": "1.2.3.4",
  "BJA": "1.3.2.4"
}
`)

type mytype map[string]string

func main() {

	ip := os.Args[1]
	username := "xxx"
	password := "xxxx"

	var data mytype
	err := json.Unmarshal(Location, &data)
	if err != nil {
		log.Fatal(err)
	}
	//fmt.Println(data)
	for k, v := range data {
		url := "http://" + v + "/nitro/v1/config/lbvserver?filter=ipv46:" + ip
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			log.Fatal(err)
		}
		req.SetBasicAuth(username, password)
		client := http.Client{}
		res, err := client.Do(req)
		if err != nil {
			log.Fatal(err)
		}

		body, err := ioutil.ReadAll(res.Body)
		res.Body.Close()
		if err != nil {
			log.Fatal(err)
		}

		js, err := simplejson.NewJson(body)
		_, ok := js.CheckGet("lbvserver")
		if ok {
			fmt.Println(k, "(", v, ")", "has", ip)
			break
		}
	}
}
