// components/shared/Footer.tsx
import { useTranslation } from 'react-i18next'

export default function Footer() {
  const { t } = useTranslation()
  return (
    <footer className="bg-gray-900 text-gray-400 py-10 mt-16">
      <div className="max-w-7xl mx-auto px-4 grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <h3 className="text-white text-lg font-bold mb-2">{t('nav.brand')}</h3>
          <p className="text-sm">{t('footer.tagline')}</p>
        </div>
        <div>
          <h4 className="text-white font-semibold mb-2">{t('footer.quickLinks')}</h4>
          <ul className="space-y-1 text-sm">
            <li><a href="/hotels"   className="hover:text-white">{t('nav.hotels')}</a></li>
            <li><a href="/login"    className="hover:text-white">{t('nav.login')}</a></li>
            <li><a href="/register" className="hover:text-white">{t('nav.register')}</a></li>
          </ul>
        </div>
        <div>
          <h4 className="text-white font-semibold mb-2">{t('footer.contact')}</h4>
          <p className="text-sm">support@hotelbook.com</p>
          <p className="text-sm">+251 911 000 000</p>
        </div>
      </div>
      <div className="text-center text-xs text-gray-600 mt-8">
        © {new Date().getFullYear()} {t('footer.copyright')}
      </div>
    </footer>
  )
}
