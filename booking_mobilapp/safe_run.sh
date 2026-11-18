#!/bin/bash
# Run the Dallol Booking Flutter app on Chrome
# This script also makes sure the backend is running

echo "🚀 Starting Dallol Booking Mobile App..."
echo ""

# Check if backend is running
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/v1/hotels/featured | grep -q "200"; then
  echo "✅ Backend API is running on http://localhost:8080"
else
  echo "⚠️  Backend not detected. Starting it now..."
  cd /home/abebe/Documents/dallolbook/dallolbookingall/booking_website
  php spark serve --host 0.0.0.0 --port 8080 &
  sleep 3
  cd /home/abebe/Documents/dallolbook/dallolbookingall/booking_mobilapp
  echo "✅ Backend started."
fi

echo ""
echo "📱 Launching Flutter app on Chrome at http://localhost:3000"
echo "   API Base URL: http://localhost:8080/api/v1"
echo ""

flutter run -d chrome --web-port 3000
