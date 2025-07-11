import React, { useState } from 'react';
import { Modal, Form, Button, Row, Col } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrash, faPlus } from '@fortawesome/free-solid-svg-icons';

export default function CrudModal({
  show,
  handleClose,
  handleSubmit,
  formData = null,
  isViewMode = false
}) {
  const equiposDisponibles = [
    { id: 1, codigo: 'F7213', nombre: 'Acer' },
    { id: 2, codigo: '712J1', nombre: 'HP' },
    { id: 3, codigo: 'UY921', nombre: 'Lenovo' },
    { id: 4, codigo: 'PQ114', nombre: 'Lenovo' }
  ];

  // Función para inicializar los valores del formulario
  const getInitialValues = () => {
    if (!formData) {
      return {
        tipoDocumento: '',
        documento: '',
        nombre: '',
        apellido: '',
        correo: '',
        tipoPersona: '',
        celular: '',
        equipos: [{ id: Date.now(), equipoId: '', equipoNombre: '' }]
      };
    }
    return {
      tipoDocumento: formData.tipoDocumento || '',
      documento: formData.documento || '',
      nombre: formData.nombre || '',
      apellido: formData.apellido || '',
      correo: formData.correo || '',
      tipoPersona: formData.tipoPersona || '',
      celular: formData.celular || '',
      equipos: formData.equipos && formData.equipos.length > 0
        ? formData.equipos
        : [{ id: Date.now(), equipoId: '', equipoNombre: '' }]
    };
  };

  // Estado del formulario
  const [formValues, setFormValues] = useState(getInitialValues());

  // Manejar cambios en los inputs
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormValues({
      ...formValues,
      [name]: value
    });
  };

  // Agregar nuevo equipo
  const agregarEquipo = () => {
    setFormValues({
      ...formValues,
      equipos: [
        ...formValues.equipos,
        { id: Date.now(), equipoId: '', equipoNombre: '' }
      ]
    });
  };

  // Eliminar equipo
  const eliminarEquipo = (id) => {
    if (formValues.equipos.length <= 1) return;
    setFormValues({
      ...formValues,
      equipos: formValues.equipos.filter(equipo => equipo.id !== id)
    });
  };

  // Manejar cambio de equipo seleccionado
  const handleCambioEquipo = (e, id) => {
    const { value } = e.target;
    const equipoSeleccionado = equiposDisponibles.find(e => e.id === parseInt(value));

    setFormValues({
      ...formValues,
      equipos: formValues.equipos.map(equipo => {
        if (equipo.id === id) {
          return {
            ...equipo,
            equipoId: value,
            equipoNombre: equipoSeleccionado
              ? `${equipoSeleccionado.codigo} - ${equipoSeleccionado.nombre}`
              : ''
          };
        }
        return equipo;
      })
    });
  };

  // Manejar envío del formulario
  const handleSubmitForm = (e) => {
    e.preventDefault();

    // Validar que haya al menos un equipo seleccionado
    const equiposValidos = formValues.equipos.filter(eq => eq.equipoId !== '');
    if (equiposValidos.length === 0) {
      alert('Debe seleccionar al menos un equipo');
      return;
    }

    // Preparar datos para enviar
    const datosParaEnviar = {
      ...formValues,
      equipos: equiposValidos
    };

    // Llamar a la función handleSubmit del componente padre
    handleSubmit(datosParaEnviar);

    // Cerrar el modal
    handleClose();
  };

  return (
    <Modal show={show} onHide={handleClose} dialogClassName="modal-lg">
      <Modal.Header>
        <Modal.Title>
          {formData?.id ? "Editar Persona" : "Nueva Persona"}
        </Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmitForm}>
        <Modal.Body>
          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Tipo documento</Form.Label>
                <Form.Select
                  name="tipoDocumento"
                  value={formValues.tipoDocumento}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                >
                  <option value="">Seleccione un tipo...</option>
                  <option value="CC">Cédula de Ciudadanía (CC)</option>
                  <option value="TI">Tarjeta de Identidad (TI)</option>
                  <option value="Pasaporte">Pasaporte</option>
                  <option value="Otro">Otro</option>
                </Form.Select>
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Documento</Form.Label>
                <Form.Control
                  type="number"
                  name="documento"
                  value={formValues.documento}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Nombre</Form.Label>
                <Form.Control
                  type="text"
                  name="nombre"
                  value={formValues.nombre}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Apellido</Form.Label>
                <Form.Control
                  type="text"
                  name="apellido"
                  value={formValues.apellido}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                />
              </Form.Group>
            </Col>

            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Correo electrónico</Form.Label>
                <Form.Control
                  type="email"
                  name="correo"
                  value={formValues.correo}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                />
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Equipos</Form.Label>
                {formValues.equipos.map((equipo) => (
                  <div key={equipo.id} className="d-flex align-items-center mb-3">
                    <Form.Select
                      name={`equipo-${equipo.id}`}
                      value={equipo.equipoId}
                      onChange={(e) => handleCambioEquipo(e, equipo.id)}
                      disabled={isViewMode}
                      className="me-2"
                    >
                      <option value="">Seleccione equipo...</option>
                      {equiposDisponibles.map(equipo => (
                        <option key={equipo.id} value={equipo.id}>
                          {equipo.codigo} - {equipo.nombre}
                        </option>
                      ))}
                    </Form.Select>

                    {!isViewMode && (
                      <Button
                        variant="outline-danger"
                        onClick={() => eliminarEquipo(equipo.id)}
                        disabled={formValues.equipos.length <= 1}
                        title="Eliminar equipo"
                        size="sm"
                      >
                        <FontAwesomeIcon icon={faTrash} />
                      </Button>
                    )}
                  </div>
                ))}

                {!isViewMode && (
                  <Button
                    variant="outline-primary"
                    onClick={agregarEquipo}
                    size="sm"
                    className="mt-2"
                    type="button"
                  >
                    <FontAwesomeIcon icon={faPlus} className="me-1" />
                    Agregar Equipo
                  </Button>
                )}
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Tipo de Persona</Form.Label>
                <Form.Select
                  name="tipoPersona"
                  value={formValues.tipoPersona}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                >
                  <option value="">Seleccione un tipo de persona...</option>
                  <option value="Aprendiz">Aprendiz</option>
                  <option value="Funcionario">Funcionario</option>
                  <option value="PersonaCorriente">Persona Corriente</option>
                </Form.Select>
              </Form.Group>

              <Form.Group className="mb-3">
                <Form.Label>Celular</Form.Label>
                <Form.Control
                  type="number"
                  name="celular"
                  value={formValues.celular}
                  onChange={handleInputChange}
                  disabled={isViewMode}
                />
              </Form.Group>
            </Col>
          </Row>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="danger" onClick={handleClose}>
            Cancelar
          </Button>
          {!isViewMode && (
            <Button variant="success" type="submit">
              Guardar
            </Button>
          )}
        </Modal.Footer>
      </Form>
    </Modal>
  );
}