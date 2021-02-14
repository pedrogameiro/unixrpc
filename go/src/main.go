package main

import (
	"client/go/build/proto/messages"
	"context"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"time"

	"google.golang.org/grpc"
)

func main() {
	conn, err := grpc.Dial(
		os.Getenv("XDG_RUNTIME_DIR")+"/unix_experiment",
		grpc.WithInsecure(),
		grpc.WithContextDialer(func(ctx context.Context, addr string) (net.Conn, error) {
			return net.DialTimeout("unix", addr, time.Second)
		}),
	)
	if err != nil {
		panic(err)
	}
	defer conn.Close()
	client := messages.NewServerClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	request := &messages.GetFortuneRequest{Offensive: true}
	response, err := client.GetFortune(ctx, request)
	if err != nil {
		panic(err)
	}

	sRequest, err := json.Marshal(request)
	if err != nil {
		panic(err)
	}
	sResponse, err := json.Marshal(response)
	if err != nil {
		panic(err)
	}

	fmt.Println(string(sRequest))
	fmt.Println(string(sResponse))
}
