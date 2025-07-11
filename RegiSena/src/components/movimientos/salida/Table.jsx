import { useState } from 'react';
import { Table, Button, Container, Card, Modal } from 'react-bootstrap';
import { FaFilePdf, FaTrash, FaPlus, FaExclamationTriangle } from 'react-icons/fa';

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
          <h2 className="mb-0">Salidas</h2>
          <Button variant="light" onClick={onCreate}>
            <FaPlus className="me-1" /> Nueva Salida
          </Button>
        </Card.Header>
        <Card.Body>
          <Table striped bordered hover responsive>
            <thead>
              <tr>
                <th>Documento</th>
                <th>Serial</th>
                <th>Salida</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, index) => (
                <tr key={index}>
                  <td>{item.documento}</td>
                  <td>{item.serial}</td>
                  <td>Ocasional</td>
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
                    >
                      <FaFilePdf className="me-1" /> Descargar PDF
                    </Button>
                    <Button 
                      variant="danger" 
                      size="sm"
                      onClick={() => handleDeleteClick(index)}
                    >
                      <FaTrash className="me-1" /> Anular
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
            Confirmar Anulación
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          ¿Estás seguro que deseas anular esta salida? Esta acción no se puede deshacer.
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={cancelDelete}>
            Cancelar
          </Button>
          <Button variant="danger" onClick={confirmDelete}>
            <FaTrash className="me-1" /> Anular
          </Button>
        </Modal.Footer>
      </Modal>

      <Modal show={show} onHide={() => setShow(false)} size="lg">
        <Modal.Header>
          <Modal.Title>Detalles de la salida</Modal.Title>
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
                <td><strong>Serial</strong></td>
                <td>{item.serial || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Centro de Formación</strong></td>
                <td>{item.centroformacion || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Vigilante</strong></td>
                <td>{item.vigilante || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Observaciones</strong></td>
                <td>{item.observaciones || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Salida</strong></td>
                <td>Ocasional</td>
              </tr>
              <tr key={index}>
                <td><strong>Dia de salida</strong></td>
                <td>{item.dia || 'No especificado'}</td>
              </tr>
              <tr key={index}>
                <td><strong>Hora de salida</strong></td>
                <td>{item.hora || 'No especificado'}</td>
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