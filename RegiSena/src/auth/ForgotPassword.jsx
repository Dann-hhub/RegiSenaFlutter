import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Form, Button, Card, Container, Alert } from 'react-bootstrap';

export default function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    try {
      // Lógica de recuperación aquí
      setMessage(`Se ha enviado un enlace a ${email}`);
      console.log('Email enviado a:', email);
    } catch (err) {
      setError('Error al enviar el correo');
    }
  };

  return (
    <Container className="d-flex align-items-center justify-content-center" style={{ minHeight: '100vh' }}>
      <Card className="w-100" style={{ maxWidth: '400px' }}>
        <Card.Body>
          <h2 className="text-center mb-4">Recuperar Contraseña</h2>
          {error && <Alert variant="danger">{error}</Alert>}
          {message && <Alert variant="success">{message}</Alert>}
          
          <Form onSubmit={handleSubmit}>
            <Form.Group className="mb-3">
              <Form.Label><strong>Correo Electrónico</strong></Form.Label>
              <Form.Control
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <Form.Text className="text-muted">
                <strong>Te enviaremos un enlace para restablecer tu contraseña</strong>
              </Form.Text>
            </Form.Group>

            <Button className="w-100 mt-3" variant='success' type="submit">
              Enviar Instrucciones
            </Button>
          </Form>
        </Card.Body>
        
        <Card.Footer className="text-center">
          <Link className='text-decoration-none text-success' to="/">Volver al inicio de sesión</Link>
        </Card.Footer>
      </Card>
    </Container>
  );
}