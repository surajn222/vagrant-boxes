package main

import (
    clientv3 "go.etcd.io/etcd/client/v3"
    "time"
	"context"
	"fmt"
	"log"
)
func main() {
	cli, err := clientv3.New(clientv3.Config{
		Endpoints:   []string{"localhost:2379"},
		DialTimeout: 5 * time.Second,
	})
	if err != nil {
		// handle error!
	}
	defer cli.Close()

    ctx, cancel := context.WithTimeout(context.Background(), 10000000)

    _, err = cli.Put(ctx, "foo", "bar")
    if err != nil {
        log.Fatal(err)
    }


    resp, err := cli.Get(ctx, "/apisix/routes/1")
    cancel()
    if err != nil {
        log.Fatal(err)
    }
    for _, ev := range resp.Kvs {
        fmt.Printf("%s : %s\n", ev.Key, ev.Value)
    }
}