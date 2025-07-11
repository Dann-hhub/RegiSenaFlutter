// components/Layout.jsx
import { Container, Row, Col } from 'react-bootstrap';
import Sidebar from './Sidebar';

export default function Layout({ children }) {
  return (
    <Container fluid>
      <Row>
        <Col xs={2} className="p-0">
          <Sidebar />
        </Col>
        <Col xs={10} className="p-4 main-content">
          {children}
        </Col>
      </Row>
    </Container>
  );
}