// components/shared/Footer.tsx
import { useTranslation } from 'react-i18next'

// ── SVG Icons (inline — no extra dependency) ────────────────────────────────
const PlayStoreIcon = () => (
  <svg viewBox="0 0 24 24" className="w-6 h-6 fill-current" aria-hidden="true">
    <path d="M3.18 23.76a2 2 0 0 0 2.09-.21l11.67-6.74-2.95-2.95L3.18 23.76zm14.44-8.35L5.27.45A2 2 0 0 0 3.18.24L14.44 11.5l3.18 3.91zM21.4 10.26l-2.72-1.57-3.42 3.31 3.42 3.31 2.75-1.59a2 2 0 0 0 0-3.46zM5.27 23.55l12.35-7.14-3.18-3.91L5.27 23.55z"/>
  </svg>
)

const AppleIcon = () => (
  <svg viewBox="0 0 24 24" className="w-6 h-6 fill-current" aria-hidden="true">
    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
  </svg>
)

const PhoneIcon = () => (
  <svg viewBox="0 0 24 24" className="w-5 h-5 fill-current" aria-hidden="true">
    <path d="M17 1H7C5.9 1 5 1.9 5 3v18c0 1.1.9 2 2 2h10c1.1 0 2-.9 2-2V3c0-1.1-.9-2-2-2zm-5 20c-.83 0-1.5-.67-1.5-1.5S11.17 18 12 18s1.5.67 1.5 1.5S12.83 21 12 21zm5-4H7V4h10v13z"/>
  </svg>
)

// ── Feature chip ────────────────────────────────────────────────────────────
const FeatureChip = ({ icon, text }: { icon: string; text: string }) => (
  <div className="flex items-center gap-2 bg-white/5 border border-white/10 rounded-full px-3 py-1.5 text-xs text-gray-300 whitespace-nowrap">
    <span>{icon}</span>
    <span>{text}</span>
  </div>
)

// ── Store button ─────────────────────────────────────────────────────────────
interface StoreButtonProps {
  href: string
  icon: React.ReactNode
  label: string
  sub: string
  comingSoon: boolean
}
const StoreButton = ({ href, icon, label, sub, comingSoon }: StoreButtonProps) => {
  const inner = (
    <div className={`
      flex items-center gap-3 px-4 py-2.5 rounded-xl border transition-all duration-200
      ${comingSoon
        ? 'border-white/15 bg-white/5 cursor-default opacity-70'
        : 'border-white/20 bg-white/10 hover:bg-white/20 hover:border-white/30 hover:scale-105 cursor-pointer'}
    `}>
      <span className="text-white">{icon}</span>
      <div className="text-left">
        <p className="text-[10px] text-gray-400 leading-none mb-0.5">{sub}</p>
        <p className="text-sm font-semibold text-white leading-none">{label}</p>
      </div>
      {comingSoon && (
        <span className="ml-1 text-[9px] font-bold text-yellow-400 bg-yellow-400/15 px-1.5 py-0.5 rounded-full uppercase tracking-wide">
          Soon
        </span>
      )}
    </div>
  )
  if (comingSoon) return <div>{inner}</div>
  return <a href={href} target="_blank" rel="noopener noreferrer">{inner}</a>
}

// ── QR code placeholder (shows a real SVG QR-like pattern) ──────────────────
const QrPlaceholder = ({ label }: { label: string }) => (
  <div className="flex flex-col items-center gap-2">
    <div className="w-20 h-20 bg-white rounded-lg p-1.5 flex items-center justify-center">
      {/* Simple QR-like SVG placeholder */}
      <svg viewBox="0 0 21 21" className="w-full h-full" aria-hidden="true">
        {/* Top-left finder */}
        <rect x="0" y="0" width="7" height="7" fill="#111" rx="1"/>
        <rect x="1" y="1" width="5" height="5" fill="white" rx="0.5"/>
        <rect x="2" y="2" width="3" height="3" fill="#111"/>
        {/* Top-right finder */}
        <rect x="14" y="0" width="7" height="7" fill="#111" rx="1"/>
        <rect x="15" y="1" width="5" height="5" fill="white" rx="0.5"/>
        <rect x="16" y="2" width="3" height="3" fill="#111"/>
        {/* Bottom-left finder */}
        <rect x="0" y="14" width="7" height="7" fill="#111" rx="1"/>
        <rect x="1" y="15" width="5" height="5" fill="white" rx="0.5"/>
        <rect x="2" y="16" width="3" height="3" fill="#111"/>
        {/* Data dots */}
        <rect x="9" y="0" width="2" height="2" fill="#111"/>
        <rect x="12" y="0" width="1" height="1" fill="#111"/>
        <rect x="9" y="3" width="1" height="1" fill="#111"/>
        <rect x="11" y="3" width="2" height="2" fill="#111"/>
        <rect x="9" y="6" width="2" height="1" fill="#111"/>
        <rect x="12" y="5" width="1" height="2" fill="#111"/>
        <rect x="8" y="8" width="2" height="2" fill="#111"/>
        <rect x="11" y="8" width="1" height="1" fill="#111"/>
        <rect x="13" y="8" width="2" height="2" fill="#111"/>
        <rect x="16" y="8" width="2" height="1" fill="#111"/>
        <rect x="19" y="8" width="2" height="2" fill="#111"/>
        <rect x="8" y="11" width="1" height="2" fill="#111"/>
        <rect x="10" y="11" width="2" height="1" fill="#111"/>
        <rect x="14" y="11" width="1" height="2" fill="#111"/>
        <rect x="17" y="11" width="3" height="1" fill="#111"/>
        <rect x="8" y="14" width="2" height="1" fill="#111"/>
        <rect x="12" y="14" width="1" height="1" fill="#111"/>
        <rect x="8" y="16" width="1" height="2" fill="#111"/>
        <rect x="10" y="17" width="2" height="1" fill="#111"/>
        <rect x="14" y="14" width="7" height="7" fill="#111" rx="1"/>
        <rect x="15" y="15" width="5" height="5" fill="white" rx="0.5"/>
        <rect x="16" y="16" width="3" height="3" fill="#111"/>
      </svg>
    </div>
    <p className="text-[10px] text-gray-500 text-center">{label}</p>
  </div>
)

// ── Main Footer ──────────────────────────────────────────────────────────────
export default function Footer() {
  const { t } = useTranslation()

  // Play Store / App Store URLs — update these when app is published
  const PLAY_STORE_URL  = 'https://play.google.com/store'
  const APP_STORE_URL   = 'https://apps.apple.com'
  const APP_NOT_LIVE    = true  // set false when published

  return (
    <footer className="bg-gray-950 text-gray-400 mt-16">

      {/* ── Mobile App Banner ───────────────────────────────────────────── */}
      <div className="border-b border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12">
          <div className="bg-gradient-to-br from-blue-900/40 via-blue-950/60 to-gray-900 border border-blue-800/30 rounded-2xl p-6 sm:p-10">
            <div className="flex flex-col lg:flex-row items-center gap-8">

              {/* Left — text + store buttons */}
              <div className="flex-1 text-center lg:text-left">
                {/* Badge */}
                <div className="inline-flex items-center gap-2 bg-blue-500/15 border border-blue-500/25 rounded-full px-3 py-1 mb-4">
                  <PhoneIcon />
                  <span className="text-blue-300 text-xs font-semibold tracking-wide uppercase">
                    EthioStay Mobile App
                  </span>
                </div>

                <h2 className="text-2xl sm:text-3xl font-bold text-white mb-3 leading-tight">
                  {t('footer.getApp')}
                </h2>
                <p className="text-gray-400 text-sm sm:text-base mb-6 max-w-lg mx-auto lg:mx-0">
                  {t('footer.getAppSub')}
                </p>

                {/* Feature chips */}
                <div className="flex flex-wrap justify-center lg:justify-start gap-2 mb-7">
                  <FeatureChip icon="⚡" text={t('footer.feature1')} />
                  <FeatureChip icon="🔄" text={t('footer.feature2')} />
                  <FeatureChip icon="🎁" text={t('footer.feature3')} />
                  <FeatureChip icon="📴" text={t('footer.feature4')} />
                </div>

                {/* Store buttons */}
                <div className="flex flex-wrap justify-center lg:justify-start gap-3">
                  <StoreButton
                    href={PLAY_STORE_URL}
                    icon={<PlayStoreIcon />}
                    label={t('footer.playStore')}
                    sub="Android"
                    comingSoon={APP_NOT_LIVE}
                  />
                  <StoreButton
                    href={APP_STORE_URL}
                    icon={<AppleIcon />}
                    label={t('footer.appStore')}
                    sub="iPhone & iPad"
                    comingSoon={APP_NOT_LIVE}
                  />
                </div>

                {APP_NOT_LIVE && (
                  <p className="text-xs text-yellow-500/80 mt-3 flex items-center gap-1 justify-center lg:justify-start">
                    <span>⏳</span>
                    <span>{t('footer.comingSoon')} — app is currently in development</span>
                  </p>
                )}
              </div>

              {/* Right — phone mockup + QR */}
              <div className="flex items-center gap-6 shrink-0">
                {/* Phone mockup */}
                <div className="hidden sm:flex flex-col items-center">
                  <div className="relative w-32 h-56 bg-gradient-to-b from-gray-800 to-gray-900 rounded-[2rem] border-2 border-gray-700 shadow-2xl overflow-hidden">
                    {/* Screen content mockup */}
                    <div className="absolute inset-1 rounded-[1.6rem] bg-gradient-to-b from-blue-700 to-blue-900 overflow-hidden">
                      {/* Status bar */}
                      <div className="h-5 bg-blue-800/50 flex items-center justify-center">
                        <div className="w-10 h-1.5 bg-blue-600 rounded-full"/>
                      </div>
                      {/* App name */}
                      <div className="px-2 pt-2 pb-1">
                        <p className="text-white text-[8px] font-bold text-center">EthioStay</p>
                      </div>
                      {/* City cards mockup */}
                      <div className="px-2 space-y-1.5">
                        {['Addis Ababa', 'Bahir Dar', 'Hawassa'].map((c) => (
                          <div key={c} className="h-10 bg-white/15 rounded-lg flex items-center px-2 gap-1.5">
                            <div className="w-7 h-7 rounded bg-white/20 shrink-0"/>
                            <div>
                              <div className="h-1.5 w-14 bg-white/60 rounded-full mb-1"/>
                              <div className="h-1 w-10 bg-white/30 rounded-full"/>
                            </div>
                          </div>
                        ))}
                      </div>
                      {/* Bottom nav mockup */}
                      <div className="absolute bottom-0 inset-x-0 h-8 bg-white/10 flex items-center justify-around px-3">
                        {['🏠','🔍','❤️','👤'].map((i) => (
                          <span key={i} className="text-[10px]">{i}</span>
                        ))}
                      </div>
                    </div>
                    {/* Notch */}
                    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-12 h-4 bg-gray-900 rounded-b-xl"/>
                  </div>
                  <p className="text-[10px] text-gray-600 mt-2">EthioStay App</p>
                </div>

                {/* QR code */}
                <QrPlaceholder label={t('footer.scanQr')} />
              </div>

            </div>
          </div>
        </div>
      </div>

      {/* ── Main footer links ────────────────────────────────────────────── */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-10">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">

          {/* Brand */}
          <div>
            <div className="flex items-center gap-2 mb-3">
              <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold text-sm">E</div>
              <span className="text-white font-bold text-lg">EthioStay</span>
            </div>
            <p className="text-sm leading-relaxed mb-4">{t('footer.tagline')}</p>
            <p className="text-xs text-gray-600">{t('footer.madeWith')}</p>
          </div>

          {/* Quick links */}
          <div>
            <h4 className="text-white font-semibold mb-3 text-sm uppercase tracking-wide">
              {t('footer.quickLinks')}
            </h4>
            <ul className="space-y-2 text-sm">
              {[
                { href: '/',          label: 'Home' },
                { href: '/hotels',    label: t('nav.hotels') },
                { href: '/login',     label: t('nav.login') },
                { href: '/register',  label: t('nav.register') },
              ].map(({ href, label }) => (
                <li key={href}>
                  <a href={href} className="hover:text-white transition-colors duration-150 flex items-center gap-1.5 group">
                    <span className="w-1 h-1 rounded-full bg-blue-500 opacity-0 group-hover:opacity-100 transition-opacity"/>
                    {label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h4 className="text-white font-semibold mb-3 text-sm uppercase tracking-wide">
              {t('footer.contact')}
            </h4>
            <ul className="space-y-2 text-sm">
              <li className="flex items-center gap-2">
                <span className="text-blue-400">✉</span>
                <a href="mailto:support@ethiostay.com" className="hover:text-white transition-colors">
                  support@ethiostay.com
                </a>
              </li>
              <li className="flex items-center gap-2">
                <span className="text-blue-400">📞</span>
                <a href="tel:+251911000000" className="hover:text-white transition-colors">
                  +251 911 000 000
                </a>
              </li>
              <li className="flex items-center gap-2">
                <span className="text-blue-400">📍</span>
                <span>Addis Ababa, Ethiopia</span>
              </li>
            </ul>
          </div>

          {/* Social */}
          <div>
            <h4 className="text-white font-semibold mb-3 text-sm uppercase tracking-wide">
              {t('footer.followUs')}
            </h4>
            <div className="flex flex-wrap gap-2">
              {[
                { label: 'Facebook',  icon: '📘', href: '#' },
                { label: 'Telegram',  icon: '✈️',  href: '#' },
                { label: 'Instagram', icon: '📸', href: '#' },
                { label: 'YouTube',   icon: '▶️',  href: '#' },
              ].map(({ label, icon, href }) => (
                <a
                  key={label}
                  href={href}
                  aria-label={label}
                  className="flex items-center gap-1.5 text-xs bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 rounded-lg px-3 py-1.5 transition-all duration-150"
                >
                  <span>{icon}</span>
                  <span className="text-gray-300">{label}</span>
                </a>
              ))}
            </div>
          </div>

        </div>
      </div>

      {/* ── Bottom bar ──────────────────────────────────────────────────── */}
      <div className="border-t border-white/5">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4 flex flex-col sm:flex-row items-center justify-between gap-2 text-xs text-gray-600">
          <span>© {new Date().getFullYear()} EthioStay — {t('footer.allRights')}</span>
          <div className="flex items-center gap-4">
            <a href="#" className="hover:text-gray-400 transition-colors">Privacy Policy</a>
            <a href="#" className="hover:text-gray-400 transition-colors">Terms of Service</a>
          </div>
        </div>
      </div>

    </footer>
  )
}
