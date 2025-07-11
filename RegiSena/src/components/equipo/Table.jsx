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
          <h2 className="mb-0">Equipos</h2>
          <Button variant="light" onClick={onCreate}>
            <FaPlus className="me-1" /> Nuevo Equipo
          </Button>
        </Card.Header>
        <Card.Body>
          <Table striped bordered hover responsive>
            <thead>
              <tr>
                <th>Marca</th>
                <th>Serial</th>
                <th>Accesorios</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, index) => (
                <tr key={index}>
                  <td>{item.marca}</td>
                  <td>{item.serial}</td>
                  <td>{item.accesorios}</td>
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
          ¿Estás seguro que deseas eliminar este equipo? Esta acción no se puede deshacer.
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
          <Modal.Title>Detalles del equipo</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Table striped bordered hover>
            {data.map((item,index)=>(
            <tbody>
              <tr key={index}>
                <td><strong>Marca del Equipo</strong></td>
                <td>{item.marca || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Serial</strong></td>
                <td>{item.serial || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Accesorios</strong></td>
                <td>{item.accesorios || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Fecha del Registro</strong></td>
                <td>{item.fechareg || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Hora del Registro</strong></td>
                <td>{item.horareg || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Colores</strong></td>
                <td>{item.color || 'No especificado'}</td>
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