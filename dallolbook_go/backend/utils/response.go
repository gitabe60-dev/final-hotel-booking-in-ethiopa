// utils/response.go — standard JSON response helpers.
// Shape: { "success": bool, "message": string, "data": any }
package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func Success(c *gin.Context, message string, data any) {
	c.JSON(http.StatusOK, gin.H{"success": true, "message": message, "data": data})
}

func Created(c *gin.Context, message string, data any) {
	c.JSON(http.StatusCreated, gin.H{"success": true, "message": message, "data": data})
}

func BadRequest(c *gin.Context, message string) {
	c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": message, "data": nil})
}

func Unauthorized(c *gin.Context, message string) {
	c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": message, "data": nil})
}

func Forbidden(c *gin.Context, message string) {
	c.JSON(http.StatusForbidden, gin.H{"success": false, "message": message, "data": nil})
}

func NotFound(c *gin.Context, message string) {
	c.JSON(http.StatusNotFound, gin.H{"success": false, "message": message, "data": nil})
}

func Conflict(c *gin.Context, message string) {
	c.JSON(http.StatusConflict, gin.H{"success": false, "message": message, "data": nil})
}

func Unprocessable(c *gin.Context, message string) {
	c.JSON(http.StatusUnprocessableEntity, gin.H{"success": false, "message": message, "data": nil})
}

func ServerError(c *gin.Context, message string) {
	c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": message, "data": nil})
}
