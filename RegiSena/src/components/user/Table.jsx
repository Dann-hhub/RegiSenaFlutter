import { useState } from 'react';
import { Table, Button, Container, Card, Modal } from 'react-bootstrap';
import { FaEdit, FaTrash, FaPlus, FaExclamationTriangle } from 'react-icons/fa';

export default function CrudTable({ data, onEdit, onDelete, onCreate }) {
  const [showConfirm, setShowConfirm] = useState(false);
  const [itemToDelete, setItemToDelete] = useState(null);
  const [estado, setEstado] = useState(false); // false = Inactivo, true = Activo
  const [show, setShow] = useState(false);

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

  return (
    <Container className="mt-4">
      <Card>
        <Card.Header className="d-flex justify-content-between align-items-center bg-success text-white">
          <h2 className="mb-0">Usuarios</h2>
          <Button variant="light" onClick={onCreate}>
            <FaPlus className="me-1" /> Nuevo Usuario
          </Button>
        </Card.Header>
        <Card.Body>
          <Table striped bordered hover responsive>
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Apellido</th>
                <th>Correo</th>
                <th>Rol</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, index) => (
                <tr key={index}>
                  <td>{item.nombre}</td>
                  <td>{item.apellido}</td>
                  <td>{item.correo}</td>
                  <td>{item.rol}</td>
                  <td>
                    <Button 
                      variant={estado ? "success" : "danger"}
                      size='sm'
                      className='me-2'
                      onClick={toggleEstado}
                    >
                      {estado ? "Activo" : "Inactivo"}
                    </Button>
                    <Button 
                      variant="info"
                      size='sm'
                      className='me-2'
                      onClick={() => setShow(true)}
                      >
                      Ver Detalles
                    </Button>
                    <Button 
                      variant="warning" 
                      size="sm" 
                      className="me-2"
                      onClick={() => onEdit(item)}
                    >
                      <FaEdit className="me-1" /> Editar
                    </Button>
                    <Button 
                      variant="danger" 
                      size="sm"
                      onClick={() => handleDeleteClick(index)}
                    >
                      <FaTrash className="me-1" /> Eliminar
                    </Button>
                  </td>
                </tr>
              ))}
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
          <Modal.Title>Detalles del Usuario</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Table striped bordered hover>
            {data.map((item,index)=>(
            <tbody>
              <tr key={index}>
                <td><strong>Documento</strong></td>
                <td>{item.documento || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Tipo Documento</strong></td>
                <td>{item.tipoDocumento || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Nombre</strong></td>
                <td>{item.nombre || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Apellido</strong></td>
                <td>{item.apellido || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Rol</strong></td>
                <td>{item.rol || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Correo</strong></td>
                <td>{item.correo || 'No especificado'}</td>
              </tr>
            </tbody>
            ))}
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