// pages/auth/ForgotPassword.tsx
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { authService } from '../../services/auth'
import Input from '../../components/shared/Input'
import Button from '../../components/shared/Button'

export default function ForgotPassword() {
  const navigate = useNavigate()
  const [step, setStep]       = useState<1 | 2>(1)
  const [phone, setPhone]     = useState('')
  const [otp, setOtp]         = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const sendOtp = async () => {
    setLoading(true)
    try {
      await authService.sendOtp(phone, 'reset')
      setStep(2); toast.success('Reset code sent!')
    } catch { toast.error('Failed to send code') }
    finally { setLoading(false) }
  }

  const reset = async () => {
    setLoading(true)
    try {
      await authService.resetPassword(phone, otp, password)
      toast.success('Password reset! Please login.')
      navigate('/login')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Reset failed')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-lg p-8">
        <h1 className="text-2xl font-bold text-center mb-2">Reset Password</h1>
        <p className="text-center text-gray-500 mb-8">We'll send a code to your phone</p>

        <div className="space-y-4">
          <Input label="Phone Number" type="tel" value={phone}
            onChange={e => setPhone(e.target.value)} placeholder="+251911000000" disabled={step === 2} />

          {step === 2 && (
            <>
              <Input label="OTP Code" value={otp} onChange={e => setOtp(e.target.value)} placeholder="6-digit code" />
              <Input label="New Password" type="password" value={password}
                onChange={e => setPassword(e.target.value)} placeholder="Min 6 characters" />
            </>
          )}

          {step === 1
            ? <Button fullWidth onClick={sendOtp} loading={loading}>Send Reset Code</Button>
            : <Button fullWidth onClick={reset}   loading={loading}>Reset Password</Button>
          }
        </div>
      </div>
    </div>
  )
}
