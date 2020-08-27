package main

import (
	"context"
	"fmt"
	"os"

	"github.com/joho/godotenv"
	"github.com/micro/go-micro/v2"
	accounts "github.com/owncloud/ocis-accounts/pkg/proto/v0"
)

func main() {
	godotenv.Load()

	// New Service
	service := micro.NewService(
		micro.Name("com.owncloud.services.client"), //name the client service
	)
	// Initialise service
	service.Init()

	// fmt.Println("MICRO_REGISTRY_ADDRESS:", os.Getenv("MICRO_REGISTRY_ADDRESS"))

	name := ""
	if len(os.Args) > 1 {
		name = os.Args[1]
	} else {
		fmt.Println("missing argument for user name")
		os.Exit(-1)
	}

	ss := accounts.NewSettingsService("com.owncloud.accounts", service.Client())
	ctx := context.Background()
	_, err := ss.Set(ctx, &accounts.Record{
		Key: name,
		Payload: &accounts.Payload{
			Account: &accounts.Account{
				StandardClaims: nil,
			},
		},
	})
	if err != nil {
		fmt.Printf("Could not create user: %v\n", err)
		os.Exit(-1)
	}
	fmt.Printf("Created User %#v\n", name)
}
