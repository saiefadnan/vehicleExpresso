import 'bootstrap/dist/css/bootstrap.min.css'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import NavbarTop from './components/NavbarTop'
import { useAuthContext } from './hooks/useAuthContext'
import AddParkAdmin from './pages/AddParkAdmin'
import AddRentInfo from './pages/AddRentInfo'
import AddVehicle from './pages/AddVehicle'
import CarInsuranceRenewal from './pages/CarInsuranceRenewal'
import Home from './pages/Home'
import Login from './pages/Login'
import PickupVanService from './pages/PickupVanService'
import RentingCars from './pages/RentingCars'
import SearchParking from './pages/SearchPaking'
import Signup from './pages/Signup'
import VehicleEntryExit from './pages/VehicleEntryExit'
import VehicleCare from './pages/VehicleCare'
import CareAdmin from './pages/CareAdmin'
import CareUser from './pages/CareUser'

function App() {
  const { user } = useAuthContext()
  console.log('login user: ', user)

  return (
    <div className="App">
      <BrowserRouter>
        <NavbarTop />
        <div className="pages">
          <main>
            <Routes>
              <Route
                path="/"
                element={<Home />}
              />
              <Route
                path="/login"
                element={!user ? <Login /> : <Navigate to="/" />}
              />
              <Route
                path="/signup"
                element={!user ? <Signup /> : <Navigate to="/" />}
              />
              <Route
                path="/searchparks"
                element={<SearchParking />}
              />
              <Route
                path="/pickupvanservice"
                element={user ? <PickupVanService /> : <Navigate to="/login" />}
              />
              <Route
                path="/rentingcars"
                element={user ? <RentingCars /> : <Navigate to="/login" />}
              />
              <Route
                path="/vehiclecare"
                element={user ? <VehicleCare /> : <Navigate to="/login" />}
              />
              <Route
                path="/vehiclecare/admin"
                element={<CareAdmin />}
              />
              <Route
                path="/vehiclecare/user"
                element={<CareUser />}
              />
              <Route
                path="/carinsurancerenewal"
                element={
                  user ? <CarInsuranceRenewal /> : <Navigate to="/login" />
                }
              />
              {user && (
                <Route
                  path="/addparkadmin"
                  element={
                    user.id < 100 ? <AddParkAdmin /> : <Navigate to="/" />
                  }
                />
              )}
              {user && (
                <Route
                  path="/addvehicle"
                  element={<AddVehicle />}
                />
              )}
              {user && (
                <Route
                  path="/vehicleentryexit"
                  element={
                    user.parkAdmin ? (
                      <VehicleEntryExit />
                    ) : (
                      <Navigate to="/login" />
                    )
                  }
                />
              )}
              {user && (
                <Route
                  path="/addrentinfo"
                  element={
                    user.parkAdmin ? <AddRentInfo /> : <Navigate to="/login" />
                  }
                />
              )}
            </Routes>
          </main>
        </div>
      </BrowserRouter>
    </div>
  )
}

export default App
