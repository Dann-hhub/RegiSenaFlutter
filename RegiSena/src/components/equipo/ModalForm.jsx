import { Modal, Form, Button } from 'react-bootstrap';

export default function CrudModal({ show, handleClose, handleSubmit, formData }) {
  return (
    <Modal show={show} onHide={handleClose}>
      <Modal.Header>
        <Modal.Title>
          {formData?.id ? "Editar Equipo" : "Nuevo Equipo"}
        </Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <Form.Group className="mb-3">
            <Form.Label>Marca del Equipo</Form.Label>
            <Form.Control
              type="text"
              name="marca"
              defaultValue={formData?.marca || ""}
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
                <Form.Label>Accesorios</Form.Label>
                <Form.Select
                  name="accesorios"
                  defaultValue={formData?.rol || ""}
                  required
                >
                  <option value="">Seleccione un accesorio...</option>
                  <option value="Mouse">Mouse</option>
                  <option value="Cargador">Cargador</option>
                  <option value="mouseCargador">Mouse - Cargador</option>
                </Form.Select>
              </Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>Fecha del Registro</Form.Label>
            <Form.Control
              type="date"
              name="fechareg"
              defaultValue={formData?.fechareg || ""}
            />
          </Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>Hora del Registro</Form.Label>
            <Form.Control
              type="time"
              name="horareg"
              defaultValue={formData?.horareg || ""}
            />
          </Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>Colores</Form.Label>
            <Form.Control
              type="color"
              name="color"
              defaultValue={formData?.color || ""}
            />
          </Form.Group>
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