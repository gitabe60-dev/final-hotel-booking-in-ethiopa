// components/shared/LanguageSwitcher.tsx
import { useState, useRef, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useTranslation } from 'react-i18next'
import { Languages, ChevronDown, Check } from 'lucide-react'

const LANGS = [
  { code: 'en', label: 'English', flag: '🇬🇧', native: 'English' },
  { code: 'am', label: 'Amharic', flag: '🇪🇹', native: 'አማርኛ' },
]

export default function LanguageSwitcher() {
  const { i18n } = useTranslation()
  const [open, setOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  const current = LANGS.find(l => l.code === i18n.language) || LANGS[0]

  // Close on outside click
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [])

  const switchTo = (code: string) => {
    i18n.changeLanguage(code)
    localStorage.setItem('lang', code)
    setOpen(false)
  }

  return (
    <div ref={ref} className="relative">
      {/* Trigger button */}
      <button
        onClick={() => setOpen(o => !o)}
        className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-gray-200 bg-white hover:bg-gray-50 hover:border-blue-300 transition-all text-sm font-medium text-gray-700 shadow-sm"
        aria-label="Switch language">
        <Languages size={15} className="text-blue-500" />
        <span className="text-base leading-none">{current.flag}</span>
        <span className="hidden sm:inline">{current.native}</span>
        <motion.span animate={{ rotate: open ? 180 : 0 }} transition={{ duration: 0.2 }}>
          <ChevronDown size={13} className="text-gray-400" />
        </motion.span>
      </button>

      {/* Dropdown */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: -8, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -8, scale: 0.95 }}
            transition={{ duration: 0.15 }}
            className="absolute right-0 top-full mt-2 w-44 bg-white rounded-xl shadow-xl border border-gray-100 overflow-hidden z-50">
            {LANGS.map(lang => (
              <button
                key={lang.code}
                onClick={() => switchTo(lang.code)}
                className={`w-full flex items-center gap-3 px-4 py-3 text-sm transition-colors ${
                  lang.code === i18n.language
                    ? 'bg-blue-50 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-50'
                }`}>
                <span className="text-xl">{lang.flag}</span>
                <div className="flex-1 text-left">
                  <p className="font-semibold leading-tight">{lang.native}</p>
                  <p className="text-xs text-gray-400">{lang.label}</p>
                </div>
                {lang.code === i18n.language && (
                  <Check size={15} className="text-blue-500 flex-shrink-0" />
                )}
              </button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
