package main

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
	"github.com/micro/go-micro/v2"
)

func main() {
	godotenv.Load()

	// New Service
	service := micro.NewService(
		micro.Name("com.owncloud.list-nodes.client"), //name the client service
	)
	// Initialise service
	service.Init()

	fmt.Println("MICRO_REGISTRY_ADDRESS:", os.Getenv("MICRO_REGISTRY_ADDRESS"))

	reg := service.Options().Registry
	svcList, err := reg.ListServices()
	if err != nil {
		fmt.Printf("Could not list services: %v\n", err)
	}

	for _, svc := range svcList {
		fmt.Printf("- Service: %v\n", svc.Name)
		for _, node := range svc.Nodes {
			fmt.Printf(" - Node: %v\n", node.Address)
		}
	}
	fmt.Println()
}
