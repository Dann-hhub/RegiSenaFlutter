import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Form, Button, Card, Container, Alert } from 'react-bootstrap';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    
    try {
      // Aquí iría tu lógica de autenticación
      console.log({ email, password });
      navigate('/dashboard-page'); // Redirige al dashboard después del login
    } catch (err) {
      setError('Credenciales incorrectas');
    }
  };

  return (
    <Container className="d-flex align-items-center justify-content-center" style={{ minHeight: '100vh' }}>
      <Card className="w-100" style={{ maxWidth: '400px' }}>
        <Card.Body>
          <h2 className="text-center mb-4">Iniciar Sesión</h2>
          {error && <Alert variant="danger">{error}</Alert>}
          
          <Form onSubmit={handleSubmit}>
            <Form.Group className="mb-3">
              <Form.Label><strong>Correo Electrónico</strong></Form.Label>
              <Form.Control
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label><strong>Contraseña</strong></Form.Label>
              <Form.Control
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </Form.Group>

            <Button className="w-100 mt-3" variant='success' type="submit">
              Ingresar
            </Button>
          </Form>

          <div className="text-center mt-3">
            <Link className='text-decoration-none text-success' to="/forgot-password">¿Olvidaste tu contraseña?</Link>
          </div>
        </Card.Body>
      </Card>
    </Container>
  );
}