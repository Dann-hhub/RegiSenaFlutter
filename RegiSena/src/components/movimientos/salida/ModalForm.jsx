import { Modal, Form, Button, Row, Col } from 'react-bootstrap';

export default function CrudModal({ show, handleClose, handleSubmit, formData }) {
  return (
    <Modal 
      show={show} 
      onHide={handleClose} 
      dialogClassName="modal-lg" // Hace el modal más grande
      centered // Centra el modal verticalmente
    >
      <Modal.Header closeButton>
        <Modal.Title>{"Nueva salida"}</Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <Row>
            {/* Columna izquierda */}
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Documento</Form.Label>
                <Form.Control
                  type="number"
                  name="documento"
                  defaultValue={formData?.documento || ""}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Serial</Form.Label>
                <Form.Control
                  type="text"
                  name="serial"
                  defaultValue={formData?.serial || ""}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Centro de formación</Form.Label>
                <Form.Control
                  type="text"
                  name="centroformacion"
                  defaultValue={formData?.centroformacion || ""}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Vigilante</Form.Label>
                <Form.Control
                  type="text"
                  name="vigilante"
                  defaultValue={formData?.vigilante || ""}
                />
              </Form.Group>
            </Col>

            {/* Columna derecha */}
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Observaciones</Form.Label>
                <Form.Control
                  type="text"
                  name="observaciones"
                  defaultValue={formData?.observaciones || ""}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Salida</Form.Label>
                <Form.Control
                  type="text"
                  name="salida"
                  placeholder='Ocasional'
                  disabled
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Dia de salida</Form.Label>
                <Form.Control
                  type="date"
                  name="dia"
                  defaultValue={formData?.dia || ""}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Hora de salida</Form.Label>
                <Form.Control
                  type="time"
                  name="hora"
                  defaultValue={formData?.hora || ""}
                />
              </Form.Group>
            </Col>
          </Row>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="danger" onClick={handleClose}>
            Cancelar
          </Button>
          <Button variant="success" type="submit">
            Guardar
          </Button>
        </Modal.Footer>
      </Form>
    </Modal>
  );
}