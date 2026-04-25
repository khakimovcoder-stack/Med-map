import { Routes, Route, Navigate } from 'react-router-dom';
import Header from './components/layout/Header.jsx';
import Footer from './components/layout/Footer.jsx';
import Sidebar from './components/layout/Sidebar.jsx';
import HomePage from './pages/HomePage.jsx';
import HospitalPage from './pages/HospitalPage.jsx';
import FloorPage from './pages/FloorPage.jsx';
import RoomPage from './pages/RoomPage.jsx';
import QrSimulationPage from './pages/QrSimulationPage.jsx';

export default function App() {
  return (
    <div className="flex min-h-screen bg-govgray-50">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <Header />
        <main className="flex-1">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/hospitals/:id" element={<HospitalPage />} />
            <Route path="/floors/:id" element={<FloorPage />} />
            <Route path="/rooms/:id" element={<RoomPage />} />
            <Route path="/qr-simulator" element={<QrSimulationPage />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </div>
  );
}
