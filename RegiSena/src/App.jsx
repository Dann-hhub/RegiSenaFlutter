import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Login from './auth/Login';
import ForgotPassword from './auth/ForgotPassword';
import CrudPageUser from './pages/CrudPageUser';
import MyProfilePage from './components/user/myProfile/Profile';
import CrudPageRoles from './pages/CrudPageRoles';
import DashboardPage  from './pages/DashboardPage';
import CrudPagePersonas  from './pages/CrudPagePersonas';
import CrudPageEquipos  from './pages/CrudPageEquipos';
import CrudPageIngresos from './pages/CrudPageIngresos';
import CrudPageSalidas from './pages/CrudPageSalidas';

export default function App() {  // ¡Asegúrate del export default!
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/crud-page-user" element={<CrudPageUser />} />
        <Route path="/my-profile" element={<MyProfilePage />} />
        <Route path="/crud-page-roles" element={<CrudPageRoles />} />
        <Route path="/crud-page-personas" element={<CrudPagePersonas />} />
        <Route path="/crud-page-equipos" element={<CrudPageEquipos />} />
        <Route path="/dashboard-page" element={<DashboardPage />} />
        <Route path="/crud-page-ingresos" element={<CrudPageIngresos />} />
        <Route path="/crud-page-salidas" element={<CrudPageSalidas />} />
      </Routes>
    </BrowserRouter>
  )
}