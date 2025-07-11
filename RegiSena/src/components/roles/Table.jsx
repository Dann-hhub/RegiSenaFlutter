import { useState } from 'react';
import { Table, Button, Container, Card, Modal } from 'react-bootstrap';
import { FaEdit, FaTrash, FaPlus, FaExclamationTriangle, FaLock } from 'react-icons/fa';

export default function CrudTable({ data, onEdit, onDelete, onCreate }) {
  const [showConfirm, setShowConfirm] = useState(false);
  const [itemToDelete, setItemToDelete] = useState(null);
  const [estado, setEstado] = useState(false);
  const [show, setShow] = useState(false);
  const [selectedItems, setSelectedItems] = useState([]);

  const handleDeleteClick = (index) => {
    setItemToDelete(index);
    setShowConfirm(true);
  };

  const confirmDelete = () => {
    onDelete(itemToDelete);
    setShowConfirm(false);
  };

  const cancelDelete = () => {
    setShowConfirm(false);
  };

  const toggleEstado = () => {
    setEstado(!estado);
  };

  const isAdmin = (nombre) => {
    return nombre.toLowerCase() === 'administrador';
  };

  const handleShowDetails = (item) => {
    setSelectedItems([item]); // Para mostrar solo el item seleccionado
    setShow(true);
  };

  return (
    <Container className="mt-4">
      <Card>
        <Card.Header className="d-flex justify-content-between align-items-center bg-success text-white">
          <h2 className="mb-0">Roles</h2>
          <Button variant="light" onClick={onCreate}>
            <FaPlus className="me-1" /> Nuevo Rol
          </Button>
        </Card.Header>
        <Card.Body>
          <Table striped bordered hover responsive>
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Permiso</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, index) => {
                const admin = isAdmin(item.nombre);
                return (
                  <tr key={index}>
                    <td>
                      {item.nombre}
                    </td>
                    <td>{Array.isArray(item.permiso) ? item.permiso.join(', ') : item.permiso}</td>
                    <td>
                      <Button 
                        variant={estado ? "success" : "danger"}
                        size='sm'
                        className='me-2'
                        onClick={toggleEstado}
                        disabled={admin}
                      >
                        {estado ? "Activo" : "Inactivo"}
                      </Button>
                      <Button 
                        variant="info"
                        size='sm'
                        className='me-2'
                        onClick={() => handleShowDetails(item)}
                      >
                        Ver Detalles
                      </Button>
                      <Button 
                        variant="warning" 
                        size="sm" 
                        className="me-2"
                        onClick={() => onEdit(item)}
                        disabled={admin}
                      >
                        <FaEdit className="me-1" /> Editar
                      </Button>
                      <Button 
                        variant="danger" 
                        size="sm"
                        onClick={() => handleDeleteClick(index)}
                        disabled={admin}
                      >
                        <FaTrash className="me-1" /> Eliminar
                      </Button>
                      {admin && (
                        <span className="ms-2 text-muted small">
                          (Acciones bloqueadas)
                        </span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </Table>
        </Card.Body>
      </Card>

      <Modal show={showConfirm} onHide={cancelDelete} centered>
        <Modal.Header className="bg-danger text-light">
          <Modal.Title>
            <FaExclamationTriangle className="me-2" />
            Confirmar Eliminación
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          ¿Estás seguro que deseas eliminar este usuario? Esta acción no se puede deshacer.
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={cancelDelete}>
            Cancelar
          </Button>
          <Button variant="danger" onClick={confirmDelete}>
            <FaTrash className="me-1" /> Eliminar
          </Button>
        </Modal.Footer>
      </Modal>

      <Modal show={show} onHide={() => setShow(false)} size="lg">
        <Modal.Header>
          <Modal.Title>Detalles del Rol</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Table striped bordered hover>
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Permisos</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              {selectedItems.map((item, index) => (
                <tr key={index}>
                  <td>{item.nombre || 'No especificado'}</td>
                  <td>{Array.isArray(item.permiso) ? item.permiso.join(', ') : item.permiso}</td>
                  <td>{estado ? "Activo" : "Inactivo"}</td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="info" onClick={() => setShow(false)}>
            Cerrar
          </Button>
        </Modal.Footer>
      </Modal>
    </Container>
  );
}