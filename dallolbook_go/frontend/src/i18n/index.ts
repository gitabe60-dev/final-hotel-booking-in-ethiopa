// i18n/index.ts — i18next configuration
import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import en from './en'
import am from './am'

const savedLang = localStorage.getItem('lang') || 'en'

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      am: { translation: am },
    },
    lng:          savedLang,
    fallbackLng:  'en',
    interpolation: { escapeValue: false },
  })

export default i18n
