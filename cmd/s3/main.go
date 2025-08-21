package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {
    ctx := context.Background()
	bucketName := os.Getenv("S3_BUCKET")
	awsEndpoint := os.Getenv("S3_LOCALSTACK_ENDPOINT")

    cfg, err := config.LoadDefaultConfig(ctx)
    if err != nil {
        log.Fatal(err)
    }

    client := s3.NewFromConfig(cfg, func(o *s3.Options){
		o.BaseEndpoint = aws.String(awsEndpoint)
	})

    
    output, err := client.GetObject(ctx, &s3.GetObjectInput{
        Bucket: aws.String(bucketName),
		Key: aws.String("go.mod"),
    })
    if err != nil {
        log.Fatal(err)
    }

    body,err := io.ReadAll(output.Body)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(string(body))
}
