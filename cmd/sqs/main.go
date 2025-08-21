package main

import (
	"context"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

func main() {
	ctx := context.Background()
	queueName := os.Getenv("SQS_QUEUE_NAME")
	awsEndpoint := os.Getenv("LOCALSTACK_ENDPOINT")

    cfg, err := config.LoadDefaultConfig(ctx)
    if err != nil {
        log.Fatal(err)
    }

	client := sqs.NewFromConfig(cfg, func(o *sqs.Options){
		o.BaseEndpoint = aws.String(awsEndpoint)
	})

	queue, err := client.GetQueueUrl(ctx, &sqs.GetQueueUrlInput{
		QueueName: aws.String(queueName),
	})
	if err != nil {
		log.Fatal(err)
	}

	_ , err = client.SendMessage(ctx, &sqs.SendMessageInput{
		QueueUrl: queue.QueueUrl,
		MessageBody: aws.String("Hello World"),
	})
	if err != nil {
		log.Fatal(err)
	}

}

