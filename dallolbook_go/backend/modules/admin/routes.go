// modules/admin/routes.go — all admin API routes.
package admin

import (
	"database/sql"

	"dallolbook/config"
	"dallolbook/middleware"
	"dallolbook/modules/notifications"

	"github.com/gin-gonic/gin"
)

func Register(rg *gin.RouterGroup, db *sql.DB, cfg *config.Config) {
	m := NewModel(db)
	h := NewHandler(m, cfg)

	admin := rg.Group("/admin")
	{
		// Public
		admin.POST("/login", h.Login)

		// All authenticated admins
		auth := middleware.AdminRequired(cfg)
		admin.GET("/profile",          auth, h.Profile)
		admin.PUT("/profile",          auth, h.UpdateProfile)
		admin.POST("/change-password", auth, h.ChangePassword)

		// Super Admin
		super := admin.Group("/super", auth, middleware.RoleRequired("super_admin"))
		{
			super.GET("/dashboard",                        h.SuperDashboard)
			super.GET("/sub-admins",                       h.SubAdmins)
			super.POST("/sub-admins",                      h.CreateSubAdmin)
			super.PUT("/sub-admins/:id",                   h.EditSubAdmin)
			super.DELETE("/sub-admins/:id",                h.DeleteSubAdmin)
			super.POST("/sub-admins/:id/assign-city",      h.AssignCity)
			super.DELETE("/sub-admins/:id/revoke-city/:city", h.RevokeCity)
			super.GET("/hotels",                           h.SuperHotels)
			super.POST("/hotels",                          h.AddHotel)
			super.PUT("/hotels/:id",                       h.EditHotel)
			super.POST("/hotels/:id/toggle",               h.ToggleHotel)
			super.GET("/bookings",                         h.SuperBookings)
			super.GET("/users",                            h.Users)
			super.GET("/brokers",                          h.SuperBrokers)
			super.GET("/managers",                         h.SuperManagers)
			super.GET("/cities",                           h.Cities)
			super.POST("/cities",                          h.AddCity)
			super.DELETE("/cities/:id",                    h.DeleteCity)
		}

		// Sub Admin
		sub := admin.Group("/subadmin", auth, middleware.RoleRequired("sub_admin"))
		{
			sub.GET("/dashboard",                     h.SubDashboard)
			sub.GET("/hotels",                        h.SubHotels)
			sub.POST("/hotels/create",                h.SubAddHotel)
			sub.PUT("/hotels/:id",                    h.SubEditHotel)
			sub.POST("/hotels/:id/toggle",            h.SubToggleHotel)
			sub.GET("/hotels/:id/payment-methods",     h.HotelPaymentMethods)
			sub.POST("/hotels/:id/payment-methods",    h.AddPaymentMethod)
			sub.PUT("/payment-methods/:id",            h.UpdatePaymentMethod)
			sub.GET("/hotels/:id/rooms",              h.Rooms)
			sub.POST("/hotels/:id/rooms",             h.AddRoom)
			sub.PUT("/hotels/:id/rooms/:rid",         h.EditRoom)
			sub.DELETE("/hotels/:id/rooms/:rid",      h.DeleteRoom)
			sub.POST("/hotels/:id/rooms/:rid/toggle", h.ToggleRoom)
			sub.GET("/bookings",                      h.SubBookings)
			sub.GET("/brokers",                       h.SubBrokers)
			sub.POST("/brokers",                      h.CreateBroker)
			sub.GET("/managers",                      h.SubManagers)
			sub.POST("/managers",                     h.CreateManager)
			sub.DELETE("/managers/:id",               h.DeleteManager)
		}

		// Broker
		broker := admin.Group("/broker", auth, middleware.RoleRequired("broker"))
		{
			broker.GET("/dashboard",       h.BrokerDashboard)
			broker.GET("/bookings",        h.BrokerBookings)
			broker.GET("/inbox",           h.Inbox)
			broker.GET("/sent",            h.Sent)
			broker.GET("/messages/:id",    h.ViewMessage)
			broker.POST("/messages",       h.SendMessage)
		}

		// Hotel Manager
		manager := admin.Group("/manager", auth, middleware.RoleRequired("hotel_manager"))
		{
			manager.GET("/dashboard",              h.ManagerDashboard)
			manager.GET("/rooms",                  h.ManagerRooms)
			manager.POST("/rooms",                 h.AddRoom)
			manager.PUT("/rooms/:rid",             h.EditRoom)
			manager.DELETE("/rooms/:rid",          h.DeleteRoom)
			manager.POST("/rooms/:rid/toggle",     h.ToggleRoom)
			manager.GET("/bookings",               h.ManagerBookings)
			manager.POST("/bookings/:id/status",   h.UpdateBookingStatus)
		manager.GET("/payments",               h.ManagerPayments)
		manager.POST("/payments/:id/verify",   h.VerifyPayment)
			manager.GET("/inbox",                  h.Inbox)
			manager.GET("/messages/:id",           h.ViewMessage)
			manager.POST("/messages",              h.SendMessage)

			// Notifications (new booking alerts, payment status updates)
			notifM := notifications.NewModel(db)
			notifH := notifications.NewHandler(notifM)
			manager.GET("/notifications",           notifH.ListAdmin)
			manager.POST("/notifications/:id/read",  notifH.ReadAdmin)
			manager.POST("/notifications/read-all",   notifH.ReadAllAdmin)
		}
	}
}
