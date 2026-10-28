// context/AuthContext.tsx — global auth state for users and admins.
import { createContext, useContext, useState, useEffect, ReactNode } from 'react'

interface User {
  id: number; first_name: string; last_name: string
  full_name?: string; email?: string; phone?: string
  status: string; role?: string
}

interface AuthContextType {
  user: User | null
  token: string | null
  adminUser: User | null
  adminToken: string | null
  setAuth: (user: User, token: string) => void
  setAdminAuth: (user: User, token: string) => void
  logout: () => void
  logoutAdmin: () => void
  isAuthenticated: boolean
  isAdminAuthenticated: boolean
}

const AuthContext = createContext<AuthContextType>({} as AuthContextType)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser]             = useState<User | null>(null)
  const [token, setToken]           = useState<string | null>(null)
  const [adminUser, setAdminUser]   = useState<User | null>(null)
  const [adminToken, setAdminToken] = useState<string | null>(null)

  // Restore from localStorage on mount
  useEffect(() => {
    const t = localStorage.getItem('token')
    const u = localStorage.getItem('user')
    if (t && u) { setToken(t); setUser(JSON.parse(u)) }

    const at = localStorage.getItem('admin_token')
    const au = localStorage.getItem('admin_user')
    if (at && au) { setAdminToken(at); setAdminUser(JSON.parse(au)) }
  }, [])

  const setAuth = (u: User, t: string) => {
    setUser(u); setToken(t)
    localStorage.setItem('token', t)
    localStorage.setItem('user', JSON.stringify(u))
  }

  const setAdminAuth = (u: User, t: string) => {
    setAdminUser(u); setAdminToken(t)
    localStorage.setItem('admin_token', t)
    localStorage.setItem('admin_user', JSON.stringify(u))
  }

  const logout = () => {
    setUser(null); setToken(null)
    localStorage.removeItem('token'); localStorage.removeItem('user')
  }

  const logoutAdmin = () => {
    setAdminUser(null); setAdminToken(null)
    localStorage.removeItem('admin_token'); localStorage.removeItem('admin_user')
  }

  return (
    <AuthContext.Provider value={{
      user, token, adminUser, adminToken,
      setAuth, setAdminAuth, logout, logoutAdmin,
      isAuthenticated: !!token,
      isAdminAuthenticated: !!adminToken,
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
