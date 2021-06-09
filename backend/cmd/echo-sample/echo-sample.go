package main

import (
	"context"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	echoadapter "github.com/awslabs/aws-lambda-go-api-proxy/echo"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type UserData struct {
	UserId      string `json:"userId"`
	DisplayName string `json:"displayname"`
	Status      string `json:"status"`
}

type User struct {
	User UserData `json:"user"`
}

type OrganizationData struct {
	OrganizationId string `json:"organizationId"`
	DisplayName    string `json:"displayname"`
	Status         string `json:"status"`
}

type Organization struct {
	Organization OrganizationData `json:"organization"`
}

var echoLambda *echoadapter.EchoLambda

func init() {
	e := echo.New()
	//define routes
	registerUserRoutes(e)
	registerOrganizationRoutes(e)

	//define CORS
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		// TODO: improve cors with cfg.CORS.AllowedOrigin(s)
		AllowOrigins: []string{"*"},
		AllowMethods: []string{echo.GET, echo.PUT, echo.POST, echo.DELETE, echo.OPTIONS},
		AllowHeaders: []string{"Accept", "Content-Type", "Content-Length", "Accept-Encoding", "X-CSRF-Token", "Authorization"},
	}))
	e.Use(middleware.Logger())

	echoLambda = echoadapter.New(e)
}

func handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return echoLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(handler)
}

func registerUserRoutes(e *echo.Echo) {
	user := e.Group("/user")
	user.GET("", getUser)
	user.POST("", createUser)
}

func registerOrganizationRoutes(e *echo.Echo) {
	organization := e.Group("/organization")
	organization.GET("", getOrganization)
	organization.PUT("", updateOrganization)
}

func getUser(c echo.Context) error {
	return c.JSON(http.StatusOK, User{
		User: UserData{UserId: "1", DisplayName: "Test", Status: "active"},
	})
}

func createUser(c echo.Context) error {
	return c.JSON(http.StatusOK, User{
		User: UserData{UserId: "2", DisplayName: "Test2", Status: "created"},
	})
}

func getOrganization(c echo.Context) error {
	return c.JSON(http.StatusOK, Organization{
		Organization: OrganizationData{
			OrganizationId: "1",
			DisplayName:    "Test organization",
			Status:         "active",
		},
	})
}

func updateOrganization(c echo.Context) error {
	return c.JSON(http.StatusOK, Organization{
		Organization: OrganizationData{
			OrganizationId: "1",
			DisplayName:    "Test organization",
			Status:         "updated",
		},
	})
}
