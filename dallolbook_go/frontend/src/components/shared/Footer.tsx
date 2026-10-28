// components/shared/Footer.tsx
export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-400 py-10 mt-16">
      <div className="max-w-7xl mx-auto px-4 grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <h3 className="text-white text-lg font-bold mb-2">DallolBook</h3>
          <p className="text-sm">Discover and book the best hotels across Ethiopia.</p>
        </div>
        <div>
          <h4 className="text-white font-semibold mb-2">Quick Links</h4>
          <ul className="space-y-1 text-sm">
            <li><a href="/hotels" className="hover:text-white">Hotels</a></li>
            <li><a href="/login"  className="hover:text-white">Login</a></li>
            <li><a href="/register" className="hover:text-white">Register</a></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-semibold mb-2">Contact</h4>
          <p className="text-sm">support@dallolbook.com</p>
          <p className="text-sm">+251 911 000 000</p>
        </div>
      </div>
      <div className="text-center text-xs text-gray-600 mt-8">
        © {new Date().getFullYear()} DallolBook. All rights reserved.
      </div>
    </footer>
  )
}
