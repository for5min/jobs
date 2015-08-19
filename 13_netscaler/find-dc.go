package main

import (
	"fmt"
	"log"
	"net"
	"encoding/json"

	"os"
	//"strings"
)

var DC = []byte(`
{
 "va2"  : "10.5.0.0/16",
 "va3"  : "10.6.0.0/16",
 "ams1" : "10.3.0.0/17",
 "fra4" : "10.2.96.0/19",
 "cal1" : "10.2.64.0/19",
 "ams2" : "10.2.96.0/19",
 "syd1" : "10.2.128.0/19",
 "syd2" : "10.2.160.0/19",
 "sin1" : "10.112.0.0/19",
 "ruh1" : "10.113.0.0/19",
 "mdl1" : "10.2.192.0/19",
 "tsg1" : "10.2.224.0/19",
 "tr1"  : "10.8.224.0/19",
 "tr3"  : "10.8.160.0/19",
 "cse1" : "10.10.0.0/19"
 }
`)

type dctype map[string]string

func main() {

	ip1 := os.Args[1]

	var data dctype
	err := json.Unmarshal(DC, &data)
	if err != nil {
		log.Fatal(err)
	}

	for k, v := range data {
		ip, ipnet, err := net.ParseCIDR(v)
		if err != nil {
			log.Fatal(err)
		}
		for ip := ip.Mask(ipnet.Mask); ipnet.Contains(ip); inc(ip) {
			//if strings.EqualFold(ip1,ip.String()) {
			//	fmt.Println(ip1, "in DC", k)
			//	break
			//}
			switch ip.String() {
			case ip1:
				fmt.Println(ip1, "in DC", k)
				break
			}
		}
	}
}

func inc(ip net.IP) {
	for j := len(ip)-1; j>=0; j-- {
		ip[j]++
		if ip[j] > 0 {
			break
		}
	}
}
