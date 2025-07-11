import { useState } from 'react';
import { Modal, Form, Button, Row, Col } from 'react-bootstrap';

export default function CrudModal({ show, handleClose, handleSubmit, initialData }) {
  const [formData, setFormData] = useState(initialData || {
    nombre: '',
    permiso: []
  });

  const permisos = [
    { value: "GR", label: "Gestionar Roles" },
    { value: "GU", label: "Gestionar Usuarios" },
    { value: "GE", label: "Gestionar Equipos" },
    { value: "GP", label: "Gestionar Personas" },
    { value: "GI", label: "Gestionar Ingresos" },
    { value: "GS", label: "Gestionar Salidas" },
  ];

  return (
    <Modal show={show} onHide={handleClose} size="lg">
      <Modal.Header>
        <Modal.Title>
          {formData?.id ? "Editar Rol" : "Nuevo Rol"}
        </Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <Form.Group className="mb-4">
            <Form.Label>Nombre del Rol</Form.Label>
            <Form.Control
              type="text"
              name="nombre"
              value={formData.nombre}
              onChange={(e) => setFormData({...formData, nombre: e.target.value})}
              required
              className="py-2"
            />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label className="mb-3">Permisos (Seleccione uno o más)</Form.Label>
            <Row>
              {permisos.map((option, index) => (
                <Col key={option.value} md={6}>
                  <Form.Check
                    type="checkbox"
                    id={`Permiso-${option.value}`}
                    label={option.label}
                    name="permiso"
                    value={option.value}
                    checked={formData.permiso.includes(option.value)}
                    onChange={(e) => {
                      const value = e.target.value;
                      setFormData(prev => ({
                        ...prev,
                        permiso: e.target.checked
                          ? [...prev.permiso, value]
                          : prev.permiso.filter(v => v !== value)
                      }));
                    }}
                    className="border p-3 rounded mb-2"
                  />
                </Col>
              ))}
            </Row>
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