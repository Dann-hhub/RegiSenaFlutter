import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Card, Button, Container, Modal, Alert, Form, Nav } from 'react-bootstrap';
import { FaLock, FaUser, FaEnvelope, FaIdCard, FaKey, FaChartBar, FaAddressBook, FaLaptop, FaChevronRight, FaChevronLeft, FaSignInAlt, FaGrinBeam } from 'react-icons/fa';

export default function ProfilePage() {
  // Datos del usuario (puedes reemplazar con los datos reales)
  const [userData, setUserData] = useState({
    nombre: 'Daniel',
    apellido: 'Espinosa',
    tipoDocumento: 'CC',
    documento: '1038867691',
    correo: 'danielespinosasierra198@gmail.com',
    rol: 'Supervisor'
  });

  // Estado para controlar el modal de cambio de contraseña
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [showSuccessAlert, setShowSuccessAlert] = useState(false);

  const handlePasswordChange = () => {
    // Aquí iría la lógica para cambiar la contraseña
    setShowPasswordModal(false);
    setShowSuccessAlert(true);
    setTimeout(() => setShowSuccessAlert(false), 3000);
  };

  return (
    <div style={{ display: 'flex' }}>
      <Nav className="flex-column sidebar bg-light p-3" style={{
        width: '250px',
        minHeight: '100vh',
        height: '100%',
        position: 'fixed',
        left: 0,
        top: 0,
        overflowY: 'auto'
      }}>
        <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
          <div>
            <Nav.Item className="mb-4">
              <h4 className="fw-bold">REGISENA</h4>
            </Nav.Item>

            <Nav.Item>
              <Link className="d-flex align-items-center ps-4 text-decoration-none text-success" to={'/my-profile'}>
                <FaGrinBeam className="me-2" />
                <span>Mi Perfil</span>
              </Link>
            </Nav.Item>

            <hr className="my-3" />

            <Nav.Item>
              <div className="mb-2 fw-semibold">DASHBOARD</div>
              <Link className="d-flex align-items-center ps-4 text-decoration-none text-success" to={'/dashboard-page'}>
                <FaChartBar className="me-2" />
                <span>Graficos</span>
              </Link>
            </Nav.Item>

            <hr className="my-3" />

            <Nav.Item>
              <div className="mb-2 fw-semibold">PERSONAS</div>
              <Link className="d-flex align-items-center ps-4 text-success text-decoration-none" to={"/crud-page-personas"}>
                <FaAddressBook className="me-2" />
                <span>Información</span>
              </Link>
              <Link className="d-flex align-items-center ps-4 text-success text-decoration-none" to={"/crud-page-equipos"}>
                <FaLaptop className="me-2" />
                <span>Equipos</span>
              </Link>
            </Nav.Item>

            <Nav.Item>
              <div className="mb-2 fw-semibold">USUARIOS</div>
              <Link className="d-flex align-items-center ps-4 text-decoration-none text-success" to={'/crud-page-user'}>
                <FaAddressBook className="me-2" />
                <span>Información</span>
              </Link>
            </Nav.Item>

            <Nav.Item>
              <div className="mb-2 fw-semibold">ROLES</div>
              <Link className="d-flex align-items-center ps-4 text-decoration-none text-success" to={'/crud-page-roles'}>
                <FaAddressBook className="me-2" />
                <span>Información</span>
              </Link>
              <Nav.Link className="d-flex align-items-center ps-4 text-success">
                <FaLock className="me-2" />
                <span>Permisos</span>
              </Nav.Link>
            </Nav.Item>

            <Nav.Item>
              <div className="mb-2 fw-semibold">MOVIMIENTOS</div>
              <Nav.Link className="d-flex align-items-center ps-4 text-success">
                <FaChevronRight className="me-2" />
                <span>Ingreso</span>
              </Nav.Link>
              <Nav.Link className="d-flex align-items-center ps-4 text-success">
                <FaChevronLeft className="me-2" />
                <span>Salida</span>
              </Nav.Link>
            </Nav.Item>

            <hr className="my-3" />
            <div className="text-center my-4">
              <img
                src={"data:image/png;base64,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"}
                alt="Logo Regisena"
                style={{
                  width: '75px',
                  height: 'auto',
                  borderRadius: '8px',
                  boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                }}
              />
            </div>

            <Nav.Item className="mt-auto">
              <Link className="d-flex align-items-center text-decoration-none text-success" to={"/"}>
                <FaSignInAlt className="me-2" />
                <span>Cerrar Sesión</span>
              </Link>
            </Nav.Item>
          </div>
        </div>
      </Nav>

      <Container className="my-5" style={{
        marginLeft: '350px',
        width: '70%',
        padding: '0 20px',
        maxWidth: '100%' // Esto evita que el contenedor sea demasiado ancho en pantallas grandes
      }}>
        <h1 className="mb-4">Mi Perfil</h1>

        {showSuccessAlert && (
          <Alert variant="success" onClose={() => setShowSuccessAlert(false)} dismissible>
            Contraseña actualizada correctamente
          </Alert>
        )}

        <Card className="shadow">
          <Card.Header className="bg-success text-white">
            <h3 className="mb-0">Información del Usuario</h3>
          </Card.Header>
          <Card.Body>
            <div className="row mb-4">
              <div className="col-md-6">
                <div className="d-flex align-items-center mb-3">
                  <FaUser className="me-3 text-success" size={20} />
                  <div>
                    <h5 className="mb-0">Nombre</h5>
                    <p className="mb-0">{userData.nombre} {userData.apellido}</p>
                  </div>
                </div>
              </div>

              <div className="col-md-6">
                <div className="d-flex align-items-center mb-3">
                  <FaIdCard className="me-3 text-success" size={20} />
                  <div>
                    <h5 className="mb-0">Documento</h5>
                    <p className="mb-0">{userData.tipoDocumento} - {userData.documento}</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="row mb-4">
              <div className="col-md-6">
                <div className="d-flex align-items-center mb-3">
                  <FaEnvelope className="me-3 text-success" size={20} />
                  <div>
                    <h5 className="mb-0">Correo Electrónico</h5>
                    <p className="mb-0">{userData.correo}</p>
                  </div>
                </div>
              </div>

              <div className="col-md-6">
                <div className="d-flex align-items-center mb-3">
                  <FaKey className="me-3 text-success" size={20} />
                  <div>
                    <h5 className="mb-0">Rol</h5>
                    <p className="mb-0">{userData.rol}</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="text-center mt-4">
              <Button
                variant="success"
                onClick={() => setShowPasswordModal(true)}
                className="px-4"
              >
                <FaLock className="me-2" />
                Cambiar Contraseña
              </Button>
            </div>
          </Card.Body>
        </Card>

        {/* Modal para cambio de contraseña */}
        <Modal show={showPasswordModal} onHide={() => setShowPasswordModal(false)} centered>
          <Modal.Header>
            <Modal.Title>Cambiar Contraseña</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <Form>
              <Form.Group className="mb-3">
                <Form.Label>Contraseña Actual</Form.Label>
                <Form.Control
                  type="password"
                  placeholder="Ingresa tu contraseña actual"
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Nueva Contraseña</Form.Label>
                <Form.Control
                  type="password"
                  placeholder="Ingresa tu nueva contraseña"
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Confirmar Nueva Contraseña</Form.Label>
                <Form.Control
                  type="password"
                  placeholder="Confirma tu nueva contraseña"
                />
              </Form.Group>
            </Form>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="danger" onClick={() => setShowPasswordModal(false)}>
              Cancelar
            </Button>
            <Button variant="success" onClick={handlePasswordChange}>
              Cambiar Contraseña
            </Button>
          </Modal.Footer>
        </Modal>
      </Container>
    </div>
  );
}