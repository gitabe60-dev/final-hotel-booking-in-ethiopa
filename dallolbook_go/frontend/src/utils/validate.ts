// utils/validate.ts — shared form validation helpers

export type FieldError = string | null

// Letters, spaces and hyphens only (names)
export const validateName = (v: string, label = 'Name'): FieldError => {
  if (!v.trim()) return `${label} is required`
  if (v.trim().length < 2) return `${label} must be at least 2 characters`
  if (!/^[A-Za-z\u00C0-\u024F\u1E00-\u1EFF\s'-]+$/.test(v.trim()))
    return `${label} must contain letters only`
  return null
}

// Ethiopian phone: 09XXXXXXXX or +2519XXXXXXX
export const validatePhone = (v: string, required = true): FieldError => {
  if (!v.trim()) return required ? 'Phone number is required' : null
  if (!/^(\+251|0)(9|7)\d{8}$/.test(v.trim()))
    return 'Enter a valid Ethiopian phone number (e.g. 0912345678)'
  return null
}

// Email format
export const validateEmail = (v: string, required = true): FieldError => {
  if (!v.trim()) return required ? 'Email is required' : null
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v.trim()))
    return 'Enter a valid email address'
  return null
}

// Password: min 6 chars, at least one letter and one number
export const validatePassword = (v: string): FieldError => {
  if (!v) return 'Password is required'
  if (v.length < 6) return 'Password must be at least 6 characters'
  if (!/[A-Za-z]/.test(v)) return 'Password must contain at least one letter'
  if (!/[0-9]/.test(v)) return 'Password must contain at least one number'
  return null
}

// Confirm password
export const validateConfirmPassword = (pass: string, confirm: string): FieldError => {
  if (!confirm) return 'Please confirm your password'
  if (pass !== confirm) return 'Passwords do not match'
  return null
}

// Date: must not be in the past
export const validateFutureDate = (v: string, label = 'Date'): FieldError => {
  if (!v) return `${label} is required`
  if (new Date(v) < new Date(new Date().toISOString().split('T')[0]))
    return `${label} cannot be in the past`
  return null
}

// Check-out must be after check-in
export const validateDateRange = (checkIn: string, checkOut: string): FieldError => {
  if (!checkIn || !checkOut) return null
  if (new Date(checkOut) <= new Date(checkIn))
    return 'Check-out must be after check-in'
  return null
}

// Transaction ID: alphanumeric
export const validateTransactionId = (v: string): FieldError => {
  if (!v.trim()) return 'Transaction ID is required'
  if (v.trim().length < 4) return 'Transaction ID is too short'
  if (!/^[A-Za-z0-9_\-]+$/.test(v.trim()))
    return 'Transaction ID can only contain letters and numbers'
  return null
}

// Generic required
export const validateRequired = (v: string, label = 'This field'): FieldError => {
  if (!v || !v.trim()) return `${label} is required`
  return null
}

// Number: positive
export const validatePositiveNumber = (v: number | string, label = 'Value'): FieldError => {
  const n = Number(v)
  if (isNaN(n) || n <= 0) return `${label} must be greater than 0`
  return null
}

// Collect all errors into a flat object
export const hasErrors = (errors: Record<string, FieldError>): boolean =>
  Object.values(errors).some(e => e !== null)
