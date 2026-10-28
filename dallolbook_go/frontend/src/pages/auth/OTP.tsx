// pages/auth/OTP.tsx
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { authService } from '../../services/auth'
import { useAuth } from '../../context/AuthContext'
import Input from '../../components/shared/Input'
import Button from '../../components/shared/Button'

export default function OTP() {
  const navigate = useNavigate()
  const { setAuth } = useAuth()
  const [phone, setPhone] = useState('')
  const [otp, setOtp]     = useState('')
  const [sent, setSent]   = useState(false)
  const [loading, setLoading] = useState(false)

  const sendOtp = async () => {
    if (!phone) { toast.error('Enter phone number'); return }
    setLoading(true)
    try {
      await authService.sendOtp(phone, 'login')
      setSent(true)
      toast.success('OTP sent!')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Failed to send OTP')
    } finally { setLoading(false) }
  }

  const verify = async () => {
    if (!otp) { toast.error('Enter OTP code'); return }
    setLoading(true)
    try {
      const res = await authService.verifyOtp(phone, otp, 'login')
      const { user, token } = res.data.data
      setAuth(user, token)
      toast.success('Logged in successfully!')
      navigate('/dashboard')
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Invalid OTP')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-lg p-8">
        <h1 className="text-2xl font-bold text-center text-blue-600 mb-2">Phone Login</h1>
        <p className="text-center text-gray-500 mb-8">Enter your phone to receive a one-time password</p>

        <div className="space-y-4">
          <Input label="Phone Number" type="tel" value={phone}
            onChange={e => setPhone(e.target.value)} placeholder="+251911000000" disabled={sent} />

          {!sent ? (
            <Button fullWidth onClick={sendOtp} loading={loading}>Send OTP</Button>
          ) : (
            <>
              <Input label="OTP Code" value={otp}
                onChange={e => setOtp(e.target.value)} placeholder="6-digit code" />
              <Button fullWidth onClick={verify} loading={loading}>Verify & Login</Button>
              <button onClick={() => setSent(false)} className="w-full text-sm text-blue-600 hover:underline">
                Change phone number
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
